#!/usr/bin/python
"""p
Finds the children of a process and runs a command with the child pid's.

Usage:
    p strace [options] [--] [<strace_args>...]
    p lsof [options] [--] [<lsof_args>...]
    p pids [options]
    p --help

    --cmd-like=starman       Find the parent process with the command like
                             this.
    --children-of-pid=<pid>  Start with this parent process
    --include-start-process  Also make use of the parent process found.
    --show-cmd               Show the command being run.

"""
import psutil
from docopt import docopt
from sys import exit
from os import system


def error(msg):
    print msg
    exit(1)


def basic_process_info(p):
    return "%s %s [%s]" % (p.pid, p.name(), p.exe())


if __name__ == '__main__':

    # FIXME: warn the user if not running as root
    args = docopt(__doc__, version='Trace run 1.0')
    parent_pid = args.get('--children-of-pid')
    proc = None
    if parent_pid:
        proc = psutil.Process(int(parent_pid))
    else:
        like = args.get('--cmd-like')
        if not like:
            error("Must specify --children-of-pid or --cmd-like")
        one = psutil.Process(1)
        all_children = one.children(recursive=True)
        matches = [c for c in all_children
                   if like in c.exe() or like in c.name()]
        if len(matches) == 0:
            error("No match found")
        elif len(matches) > 1:
            error("Too many process were a potential match, %s"
                  % ', '.join([basic_process_info(p) for p in matches]))
        proc = matches[0]

    pids = [p for p in proc.children(recursive=True)]
    if args.get('--include-start-process'):
        pids.append(proc)

    if len(pids) == 0:
        error("Failed to find process")

    cmd = None
    for c in ('strace', 'lsof'):
        if args.get(c):
            cmd = c
            break
    if cmd:
        process_args = " -p ".join([p.pid for p in pids])
        command = "%s -p %s %s" % (cmd, process_args,
                                   ' '.join(args.get('<%s_args>' % cmd, [])))
        if args.get('--show-cmd'):
            print command
        system(command)
    else:
        if args.get('pids'):
            for p in pids:
                print basic_process_info(p)
        else:
            error("No command specified")
