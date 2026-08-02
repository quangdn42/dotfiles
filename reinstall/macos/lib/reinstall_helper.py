#!/usr/bin/env python3

import argparse
import fnmatch
import hashlib
import json
import os
import posixpath
import re
import stat
import sys
import tarfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

CACHE_NAMES = {
    'node_modules': 'javascript dependencies',
    '.venv': 'python virtual environment',
    'venv': 'python virtual environment',
    '__pycache__': 'python bytecode cache',
    '.pytest_cache': 'pytest cache',
    '.mypy_cache': 'mypy cache',
    '.ruff_cache': 'ruff cache',
    '.tox': 'tox environment',
    '.nox': 'nox environment',
    '.cache': 'project cache',
    '.parcel-cache': 'parcel cache',
    '.turbo': 'turbo cache',
    '.next': 'Next.js output',
    '.nuxt': 'Nuxt output',
    '.zig-cache': 'Zig cache',
    'zig-cache': 'Zig cache',
    'zig-out': 'Zig output',
}

SAFE_ID = re.compile(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$')
ALLOWED_DISPOSITIONS = {'encrypted_archive', 'sync_only', 'intentionally_skipped'}
ALLOWED_ADAPTERS = {'filesystem', 'manual'}
ALLOWED_RESTORE_POLICIES = {'merge_no_overwrite', 'stage_only', 'human_verify'}


def utc_now():
    return (
        datetime.now(timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace('+00:00', 'Z')
    )


def write_json(path, value):
    destination = Path(path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_name(destination.name + '.partial')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    os.replace(temporary, destination)


def load_archive(config_path, archive_id):
    config = json.loads(Path(config_path).read_text())
    if config.get('schema_version') != 1:
        raise ValueError('unsupported archive configuration schema')
    matches = [
        item for item in config.get('archives', []) if item.get('id') == archive_id
    ]
    if len(matches) != 1:
        raise ValueError(f'archive id must appear exactly once: {archive_id}')
    return matches[0]


def validate_config(args):
    config = json.loads(Path(args.config).read_text())
    if config.get('schema_version') != 1:
        raise ValueError('unsupported archive configuration schema')
    archives = config.get('archives')
    if not isinstance(archives, list) or not archives:
        raise ValueError('archive configuration must contain a nonempty archives array')
    ids = set()
    filenames = set()
    for archive in archives:
        archive_id = archive.get('id')
        if (
            not isinstance(archive_id, str)
            or not SAFE_ID.fullmatch(archive_id)
            or archive_id in {'.', '..'}
        ):
            raise ValueError(f'unsafe archive id: {archive_id!r}')
        if archive_id in ids:
            raise ValueError(f'duplicate archive id: {archive_id}')
        ids.add(archive_id)
        disposition = archive.get('disposition')
        if disposition not in ALLOWED_DISPOSITIONS:
            raise ValueError(f'invalid disposition for {archive_id}: {disposition!r}')
        policy = archive.get('restore_policy')
        if policy not in ALLOWED_RESTORE_POLICIES:
            raise ValueError(f'invalid restore policy for {archive_id}: {policy!r}')
        if disposition != 'encrypted_archive':
            if not archive.get('reason'):
                raise ValueError(
                    f'non-archive disposition requires a reason: {archive_id}'
                )
            continue
        filename = archive.get('filename')
        if (
            not isinstance(filename, str)
            or Path(filename).name != filename
            or not filename.endswith('.tar.zst.age')
            or not SAFE_ID.fullmatch(filename.removesuffix('.tar.zst.age'))
        ):
            raise ValueError(f'unsafe archive filename for {archive_id}: {filename!r}')
        if filename in filenames:
            raise ValueError(f'duplicate archive filename: {filename}')
        filenames.add(filename)
        adapter = archive.get('capture_adapter')
        if adapter not in ALLOWED_ADAPTERS:
            raise ValueError(f'invalid capture adapter for {archive_id}: {adapter!r}')
        if not isinstance(archive.get('sources', []), list) or not isinstance(
            archive.get('excludes', []), list
        ):
            raise TypeError(f'sources and excludes must be arrays: {archive_id}')
        for value in archive.get('sources', []) + archive.get('excludes', []):
            if not isinstance(value, str):
                raise TypeError(
                    f'source and exclusion values must be strings: {archive_id}'
                )
            safe_relative(value)
        for value in archive.get('required_member_prefixes', []):
            safe_relative(value)
    write_json(args.output, {'validated_at': utc_now(), 'archive_count': len(archives)})


def safe_relative(value):
    path = PurePosixPath(value)
    if not value or path.is_absolute() or '..' in path.parts:
        raise ValueError(f'unsafe relative path: {value!r}')
    normalized = path.as_posix()
    return normalized.removeprefix('./')


def excluded(relative, patterns):
    return any(
        relative == pattern.rstrip('/')
        or relative.startswith(pattern.rstrip('/') + '/')
        or fnmatch.fnmatchcase(relative, pattern)
        for pattern in patterns
    )


def inventory(args):
    home = Path(args.home).resolve()
    archive = load_archive(args.config, args.archive)
    sources = [safe_relative(value) for value in archive.get('sources', [])]
    excludes = [safe_relative(value) for value in archive.get('excludes', [])]
    present = []
    missing = []
    file_count = 0
    source_bytes = 0
    fingerprint = hashlib.sha256()

    for source in sources:
        path = home / source
        if not os.path.lexists(path):
            missing.append(source)
            continue
        present.append(source)
        stack = [(path, source)]
        while stack:
            current, relative = stack.pop()
            if excluded(relative, excludes):
                continue
            info = current.lstat()
            file_count += 1
            kind = (
                'directory'
                if stat.S_ISDIR(info.st_mode)
                else 'symlink'
                if stat.S_ISLNK(info.st_mode)
                else 'file'
            )
            link = os.readlink(current) if stat.S_ISLNK(info.st_mode) else ''
            fingerprint.update(
                json.dumps(
                    [
                        relative,
                        kind,
                        info.st_mode,
                        info.st_size,
                        info.st_mtime_ns,
                        info.st_dev,
                        info.st_ino,
                        link,
                    ],
                    separators=(',', ':'),
                ).encode()
            )
            fingerprint.update(b'\n')
            if stat.S_ISREG(info.st_mode):
                source_bytes += info.st_size
            if stat.S_ISDIR(info.st_mode):
                with os.scandir(current) as entries:
                    children = sorted(
                        entries, key=lambda entry: entry.name, reverse=True
                    )
                for child in children:
                    child_path = Path(child.path)
                    child_relative = child_path.relative_to(home).as_posix()
                    stack.append((child_path, child_relative))

    if archive.get('required', False) and missing:
        raise ValueError(f'required sources are missing: {", ".join(missing)}')

    plan = dict(archive)
    plan.update(
        {
            'generated_at': utc_now(),
            'home': str(home),
            'present_sources': present,
            'missing_sources': missing,
            'source_files': file_count,
            'source_bytes': source_bytes,
            'inventory_sha256': fingerprint.hexdigest(),
        }
    )
    write_json(args.output, plan)


def normalized_member(name):
    if not name:
        raise ValueError('archive contains an empty member name')
    path = PurePosixPath(name)
    if path.is_absolute() or '..' in path.parts:
        raise ValueError(f'unsafe archive member: {name!r}')
    normalized = posixpath.normpath(name)
    if normalized in ('', '.') or normalized.startswith('../'):
        raise ValueError(f'unsafe archive member: {name!r}')
    return normalized


def validate_link(member, normalized):
    if not member.issym() and not member.islnk():
        return
    target = member.linkname
    if not target or PurePosixPath(target).is_absolute():
        raise ValueError(f'unsafe link target for {member.name!r}: {target!r}')
    if member.issym():
        resolved = posixpath.normpath(
            posixpath.join(posixpath.dirname(normalized), target)
        )
    else:
        resolved = posixpath.normpath(target)
    if resolved == '..' or resolved.startswith(('../', '/')):
        raise ValueError(f'link escapes archive root for {member.name!r}: {target!r}')


def validate_tar(args):
    seen = set()
    records = []
    with tarfile.open(fileobj=sys.stdin.buffer, mode='r|*') as archive:
        for member in archive:
            normalized = normalized_member(member.name)
            if normalized in seen:
                raise ValueError(f'duplicate archive member: {normalized!r}')
            seen.add(normalized)
            validate_link(member, normalized)
            if not (
                member.isfile() or member.isdir() or member.issym() or member.islnk()
            ):
                raise ValueError(f'unsupported archive member type: {member.name!r}')
            records.append(
                {
                    'path': normalized,
                    'type': 'file'
                    if member.isfile()
                    else 'directory'
                    if member.isdir()
                    else 'symlink'
                    if member.issym()
                    else 'hardlink',
                    'size': member.size,
                    'link': member.linkname or None,
                }
            )
    if not records:
        raise ValueError('archive contains no members')
    write_json(
        args.output,
        {
            'validated_at': utc_now(),
            'archive_sha256': args.archive_sha256,
            'members': records,
        },
    )


def directory_size(path, expected_device=None):
    total = 0
    for root, dirs, files in os.walk(path, followlinks=False):
        root_info = Path(root).lstat()
        if expected_device is not None and root_info.st_dev != expected_device:
            raise ValueError(f'cleanup candidate crosses a filesystem boundary: {root}')
        for name in files:
            candidate = Path(root) / name
            try:
                info = candidate.lstat()
                if expected_device is not None and info.st_dev != expected_device:
                    raise ValueError(
                        f'cleanup candidate crosses a filesystem boundary: {candidate}'
                    )
                total += info.st_size
            except FileNotFoundError:
                pass
        for name in dirs:
            candidate = Path(root) / name
            info = candidate.lstat()
            if expected_device is not None and info.st_dev != expected_device:
                raise ValueError(
                    f'cleanup candidate crosses a filesystem boundary: {candidate}'
                )
        dirs[:] = [name for name in dirs if not (Path(root) / name).is_symlink()]
    return total


def remove_tree_one_filesystem(path, expected_device):
    for entry in os.scandir(path):
        candidate = Path(entry.path)
        info = candidate.lstat()
        if info.st_dev != expected_device:
            raise ValueError(
                f'refusing to delete across a filesystem boundary: {candidate}'
            )
        if stat.S_ISDIR(info.st_mode) and not stat.S_ISLNK(info.st_mode):
            remove_tree_one_filesystem(candidate, expected_device)
        else:
            candidate.unlink()
    path.rmdir()


def cleanup_plan(args):
    home = Path(args.home).resolve()
    roots = [home / 'projects', home / 'workspaces']
    candidates = []
    visited = set()

    for root in roots:
        if not root.is_dir():
            continue
        for current, dirs, files in os.walk(root, topdown=True, followlinks=False):
            current_path = Path(current)
            kept_dirs = []
            for name in dirs:
                path = current_path / name
                if name in CACHE_NAMES:
                    info = path.lstat()
                    candidates.append(
                        {
                            'path': str(path),
                            'relative_path': str(path.relative_to(home)),
                            'reason': CACHE_NAMES[name],
                            'device': info.st_dev,
                            'inode': info.st_ino,
                            'mtime_ns': info.st_mtime_ns,
                            'bytes': directory_size(path, info.st_dev),
                        }
                    )
                    visited.add(path)
                else:
                    kept_dirs.append(name)
            dirs[:] = kept_dirs
            if 'Cargo.toml' in files:
                target = current_path / 'target'
                if target.is_dir() and target not in visited:
                    info = target.lstat()
                    candidates.append(
                        {
                            'path': str(target),
                            'relative_path': str(target.relative_to(home)),
                            'reason': 'Rust build output adjacent to Cargo.toml',
                            'device': info.st_dev,
                            'inode': info.st_ino,
                            'mtime_ns': info.st_mtime_ns,
                            'bytes': directory_size(target, info.st_dev),
                        }
                    )
                    dirs[:] = [name for name in dirs if name != 'target']

    candidates.sort(key=lambda item: item['path'])
    downloads = []
    downloads_root = home / 'Downloads'
    if downloads_root.is_dir():
        for item in downloads_root.iterdir():
            size = directory_size(item) if item.is_dir() else item.lstat().st_size
            downloads.append({'path': str(item), 'bytes': size})
        downloads.sort(key=lambda item: (item['bytes'], item['path']))

    write_json(
        args.output,
        {
            'schema_version': 1,
            'generated_at': utc_now(),
            'home': str(home),
            'candidates': candidates,
            'downloads': downloads,
        },
    )


def validate_cleanup_candidate(home, candidate):
    path = Path(candidate['path'])
    resolved_parent = path.parent.resolve()
    allowed_roots = [(home / 'projects').resolve(), (home / 'workspaces').resolve()]
    if not any(
        resolved_parent == root or root in resolved_parent.parents
        for root in allowed_roots
    ):
        raise ValueError(f'cleanup path escapes allowed roots: {path}')
    info = path.lstat()
    expected = (candidate['device'], candidate['inode'], candidate['mtime_ns'])
    observed = (info.st_dev, info.st_ino, info.st_mtime_ns)
    if observed != expected:
        raise ValueError(f'cleanup candidate changed after review: {path}')


def cleanup_apply(args):
    plan = json.loads(Path(args.plan).read_text())
    home = Path(plan['home']).resolve()
    removed = []
    for candidate in plan.get('candidates', []):
        validate_cleanup_candidate(home, candidate)
        path = Path(candidate['path'])
        if path.is_symlink() or not path.is_dir():
            raise ValueError(f'cleanup candidate is not a directory: {path}')

    for candidate in plan.get('candidates', []):
        path = Path(candidate['path'])
        validate_cleanup_candidate(home, candidate)
        remove_tree_one_filesystem(path, candidate['device'])
        removed.append(str(path))
    write_json(
        args.output,
        {
            'applied_at': utc_now(),
            'plan': str(Path(args.plan).resolve()),
            'removed': removed,
        },
    )


def cleanup_verify(args):
    plan = json.loads(Path(args.plan).read_text())
    remaining = [
        candidate['path']
        for candidate in plan.get('candidates', [])
        if Path(candidate['path']).exists()
    ]
    if remaining:
        raise ValueError('cleanup candidates remain: ' + ', '.join(remaining))
    write_json(
        args.output,
        {
            'verified_at': utc_now(),
            'plan': str(Path(args.plan).resolve()),
            'remaining': [],
        },
    )


def parser():
    result = argparse.ArgumentParser()
    commands = result.add_subparsers(dest='command', required=True)

    config_parser = commands.add_parser('validate-config')
    config_parser.add_argument('--config', required=True)
    config_parser.add_argument('--output', required=True)
    config_parser.set_defaults(handler=validate_config)

    inventory_parser = commands.add_parser('inventory')
    inventory_parser.add_argument('--home', required=True)
    inventory_parser.add_argument('--config', required=True)
    inventory_parser.add_argument('--archive', required=True)
    inventory_parser.add_argument('--output', required=True)
    inventory_parser.set_defaults(handler=inventory)

    tar_parser = commands.add_parser('validate-tar')
    tar_parser.add_argument('--output', required=True)
    tar_parser.add_argument('--archive-sha256', required=True)
    tar_parser.set_defaults(handler=validate_tar)

    cleanup_parser = commands.add_parser('cleanup-plan')
    cleanup_parser.add_argument('--home', required=True)
    cleanup_parser.add_argument('--output', required=True)
    cleanup_parser.set_defaults(handler=cleanup_plan)

    apply_parser = commands.add_parser('cleanup-apply')
    apply_parser.add_argument('--plan', required=True)
    apply_parser.add_argument('--output', required=True)
    apply_parser.set_defaults(handler=cleanup_apply)

    verify_parser = commands.add_parser('cleanup-verify')
    verify_parser.add_argument('--plan', required=True)
    verify_parser.add_argument('--output', required=True)
    verify_parser.set_defaults(handler=cleanup_verify)
    return result


def main():
    args = parser().parse_args()
    try:
        args.handler(args)
    except (
        OSError,
        TypeError,
        ValueError,
        json.JSONDecodeError,
        tarfile.TarError,
    ) as error:
        print(f'error: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
