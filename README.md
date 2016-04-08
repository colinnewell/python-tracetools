# python-tracetools
Quick scripts to help with tracing stuff on linux

Currently just a quick utility for running lsof or strace.

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

For example,

```
sudo ./p pids --cmd-like="starman master"
4085 starman worker  [/opt/perl-5.14.4/bin/perl]
4086 starman worker  [/opt/perl-5.14.4/bin/perl]
4087 starman worker  [/opt/perl-5.14.4/bin/perl]
4088 starman worker  [/opt/perl-5.14.4/bin/perl]
4089 starman worker  [/opt/perl-5.14.4/bin/perl]
```
