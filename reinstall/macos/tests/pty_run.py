#!/usr/bin/env python3

import os
import pty
import sys


def main():
    if len(sys.argv) < 3:
        print('usage: pty_run.py <input> <command> [arguments...]', file=sys.stderr)
        return 2
    input_text = sys.argv[1]
    command = sys.argv[2:]
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(command[0], command)
    os.write(fd, (input_text + '\n').encode())
    try:
        while True:
            data = os.read(fd, 4096)
            if not data:
                break
            os.write(sys.stdout.fileno(), data)
    except OSError:
        pass
    _, status = os.waitpid(pid, 0)
    return os.waitstatus_to_exitcode(status)


if __name__ == '__main__':
    raise SystemExit(main())
