#!/usr/bin/python
"""p
Finds the children of a process and runs a command with the child pid's.

Usage:
    p strace [options] [--] [<strace_args>...]
    p lsof [options] [--] [<lsof_args>...]
    p --help

    --cmd-like=starman       Find the parent process with the command like this.
    --children-of-pid=<pid>  Start with this parent process
    --include-start-process  Also make use of the parent process found.
    --show-cmd               Show the command being run.

"""
import psutil
from docopt import docopt
from sys import exit
from os import system

if __name__ == '__main__':

    args = docopt(__doc__, version='Trace run 1.0')
    parent_pid = args.get('--children-of-pid')
    if not parent_pid:
        like = args.get('--cmd-like')
        if not like:
            print "Must specify --children-of-pid or --cmd-like"
            exit(1)
        # FIXME: figure out parent_pid
    proc = psutil.Process(int(parent_pid))
    pids = [str(p.pid) for p in proc.children(recursive=True)]
    if args.get('--include-start-process'):
        pids.append(str(parent_pid))
    if len(pids) == 0:
        print "Failed to find process"
        exit(1)
    for c in ('strace', 'lsof'):
        if args.get(c):
            cmd = c
            break
    process_args = " -p ".join(pids)
    command = "%s -p %s %s" % (cmd, process_args, ' '.join(args.get('<%s_args>' % cmd, [])))
    if args.get('--show-cmd'):
        print command 
    system(command)
