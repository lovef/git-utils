#!/usr/bin/env python3

import sys
import subprocess
import argparse
import re

helpText = """creates commit with a message including issue number from branch name

Given branch 123-branch-name
When: git cm My message
Then: git commit -m'rel #123 My message'"""

def parseArguments(argv):
    global args
    parser = argparse.ArgumentParser(
        "git cm",
        description=helpText, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("message", nargs="+", help="Message")
    parser.add_argument("-a", "--all", help="Commit all changes",
                        action="store_true")
    parser.add_argument("-n", "--new", help="Add all files before commit",
                        action="store_true")
    parser.add_argument("-w", "--amend", help="Amend (think 're-word')",
                        action="store_true")
    parser.add_argument("-d", "--dry-run", help="Do not commit, just log",
                        action="store_true")
    args = parser.parse_args(argv)

def main(argv=sys.argv[1:]):
    parseArguments(argv)
    message = " ".join(args.message)
    if args.dry_run:
        printGrey("dry run")

    try:
        issuePattern = re.compile("^\d+")
        refName = subprocess \
            .check_output(['git', 'symbolic-ref', '--quiet', '--short', 'HEAD']) \
            .decode().rstrip()
        issue = issuePattern.match(refName).group()
        commit(f"rel #{issue} {message}")
    except:
        printGrey("Could not parse issue")
        commit(message)


def commit(message):
    if args.new:
        run(['git', 'add', '.'])
    extra = []
    if args.all:
        extra += ["--all"]
    if args.amend:
        extra += ["--amend"]
    run(['git', 'commit', '-m', message, *extra])


def run(command):
    quotedArgs = [quote(a) for a in command]
    printGrey(*quotedArgs)
    if not args.dry_run:
        subprocess.run(command)


def quote(arg):
    return f"'{arg}'" if " " in arg else arg


def printGrey(*args):
    print(*grey(*args))


def grey(*args):
    if len(args) > 0:
        args = list(args)
        args[0] = "\33[90m" + args[0]
        args[-1] += "\33[0m"
    return args


if __name__ == '__main__':
    main()
