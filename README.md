# bmark
A simple bash function to switch between bookmarked directories

## Installation
To be able to change directories, bmark can not be run in a subshell. Therefore it must be loaded as a function into the current shell. bmark also requires a file to store the bookmarked locations.

### Load the function
To load the bmark function source the script:
```
. path/to/bmark.sh
```

### Set up the bookmark file
To set up the bookmark file set the variable `$BMARKFILE` to your desired location:
```
$BMARKFILE=path/to/bmarkfile.txt
```
The file can have any name. It is not required to set the variable using export (bmark does not run in a subshell).

### Set up bmark for regular usage
To always have bmark available, just add the commands from the previous sections to your `.bashrc`, `.zshrc`, `.profile` or whatever file you use for startup scripts on your system.

For example, I added the following lines to my `.zprofile`
```
BMARKFILE=~/.bmark
. ~/Documents/bmark.sh
````

## Usage
To get usage information run `bmark` without any arguments

```
Usage: bmark  {BMARK} go to {BMARK}
      -a {BMARK} add bookmark named {BMARK} to current directory
      -a {BMARK} {DIR} add bookmark named {BMARK} to {DIR}
      -r {BMARK} remove bookmark named {BMARK}
      -l         list all bookmarks
```
