#!/usr/bin/env python3

import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="lovef.git",
    version="0.0.1",
    author="lovef",
    author_email="lovef.code@gmail.com",
    description="A collection of git utility scripts",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/lovef/git-utils",
    packages=setuptools.find_packages(),
    entry_points={
        'console_scripts': [
            'git-cm=lovef.git.cm:main',
        ],
    },
    scripts=[
        "bin/git-prune-merged",
        "bin/git-start",
        "bin/git-sync",
        "bin/git-upload",
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.8',
)
