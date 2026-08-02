#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

case "${1:---scan}" in
--scan)
	exec "$script_dir/reinstall" cleanup plan
	;;
--apply)
	"$script_dir/reinstall" cleanup apply
	exec "$script_dir/reinstall" cleanup verify
	;;
*)
	printf 'Usage: %s [--scan|--apply]\n' "$0" >&2
	exit 2
	;;
esac
