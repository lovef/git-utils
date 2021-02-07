#!/usr/bin/env python3

"""
Experimental unittest wrapper to allow test execution shorthand
    $ test/test_example.py
Instead of
    $ python3 -m test.test_example
Given
    $ cat test/test_example.py
    #!/usr/bin/env python3
    import unittest
    ...
    if __name__ == '__main__':
        unittest.main()
"""

from pathlib import Path
import sys
import subprocess

root = Path(__file__).parent.parent

class TestCase:
    pass

def main():
    testFile = Path(sys.argv[0]).absolute().relative_to(root)
    module = ".".join(testFile.parts[:-1] + (testFile.stem,))
    run(sys.executable, "-m", module)

def run(*args):
    print(*grey(*args))
    subprocess.check_output(args, cwd=str(root))

def grey(*args):
    if len(args) > 0:
        args = list(args)
        args[0] = "\33[90m" + args[0]
        args[-1] += "\33[0m"
    return args

if __name__ == '__main__':
    run(sys.executable, "-m", "unittest")
