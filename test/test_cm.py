#!/usr/bin/env python3

import lovef.git.cm
import unittest

class Tests(unittest.TestCase):

    def test_dry_run(self):
        lovef.git.cm.main(["--dry-run", "message"])

if __name__ == '__main__':
    unittest.main()
