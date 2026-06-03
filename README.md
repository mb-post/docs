#  MB-POST user manual

##  How to build

1. Clone this Git repository to your local machine.

2. Install the required packages.

```bash
$ brew install make librsvg pandoc python
$ brew install --cask mactex
```

3. Use `make` to build HTML or PDF files.

```bash
$ cd manual

$ make html-en
# or
$ make html-ja
# or
$ make pdf-en
# or
$ make pdf-ja
```

