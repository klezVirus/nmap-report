# nmap-report
A simple tool that can be use to extract usful information from a nmap scan

## Overview

This tool is a simple utility that can be used to extract information from a simple text-based nmap report (-oN).

Currently, the script permits to isolate various info on services scanned, and to auto generate additional input files for other tools, like dirb, nikto or sslscan.

## Install

To install, just download the repo and execute the `install.sh` file. The tool can also be run from the directory, with minor mods.

```
git clone git@github.com:klezVirus/nmap-report.git
cd ./nmap-report
chmod +x *.sh
./install.sh
```

## Usage

The tool is very simple to use, as observable from the help:

```
[*] Usage:
[*] /usr/local/bin/nmap-report.sh [-r] [-n|-e] [-d] <NMAP-FILE>

        -r: Build a reusable version of the report
        -n: Build target files for dirb nikto whatweb sslscan iker yawast
        -e: Executes dirb nikto whatweb sslscan iker yawast [implies -n]
        -d: Show debug messages
```

## Issues

Feel free to open an issue if anything is not working properly.