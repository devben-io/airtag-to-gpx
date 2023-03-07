# Airtag-to-GPX
This is a script that fetches the locations of airtags from the local cache of the FindMy.app and creates `*.gpx` files from them.

It's useful for tracking the history of an airtag's locations.

(Credits go to [henrik242](https://gist.github.com/henrik242/1da3a252ca66fb7d17bca5509a67937f) for inspiring this.)

## Prerequisite
- a Mac computer (sorry Linux & other OS do not work) =(
- `jq`
- your terminal app (e.g. iTerm2) or `/usr/sbin/cron` has [FullDisk access](https://osxdaily.com/2018/10/09/fix-operation-not-permitted-terminal-error-macos/)

## Prepare
- If not already done, make the script executable:
  ```bash
  $ chmod +x <PATH-TO-REPO>/airtag-to-gpx.sh
  ```
- The **Find My.app** must be running & remain open for regular updates of the local cache.

## Usage
```bash
# generate gpx of all airtags
$ ./airtag-to-gpx.sh

# generate gpx of a specific airtag
$ ./airtag-to-gpx.sh <AIRTAG-NAME>
# e.g.
$ ./airtag-to-gpx.sh Wallet
```

The script runs only once and is meant to be used with a cronjob (or something similar). For testing you can run it indefinitely like this:
```bash
# runs every minute
$ while true; do ./airtag-to-gpx.sh; echo -n "."; sleep 60; done
```

## Environment variables
`OUTPUT_DIR` 
- default: `$HOME/Desktop/airtag-gpx`
- Place where the `gpx` are saved to
- Contains final `gpx` files (merged from all days)

`TMP_DIR`
- default: `$HOME/Desktop/airtag-gpx/tmp-data/`
- Working directory
- Contains daily `gpx` files and other files

## Known Issues
1. Airtag names with whitespaces break the `jq` query
    - Can be mitigated by renaming airtags to something w/o whithespaces