Simple script to manage playlists in m3u format using `fzf` and
play them using `nvlc`.

# Usage

```
Usage: ply [OPTIONS]

ply without args will play DEFAULT playlist

Options:
    -l, --list        list contents of current DEFAULT playlist
    -b, --build       build DEFAULT playlist
    -s, --save        save DEFAULT playlist as
    -c, --choose      choose from saved playlists to play
        --set-def     make chosen playlist as DEFAULT playlist
    -d, --delete      delete chosen playlist
    -a, --append      append entries to chosen playlist
    -r, --remove      remove entries from chosen playlist
```

# Requirements

- [`fzf`](https://github.com/junegunn/fzf)
- `VLC` bundled with `nvlc`

# Installation

1. Clone this repository.
```shell
$ git clone https://github.com/wustho/ply.sh  ply
$ cd ply
```

2. Edit these lines to suit your environment from `ply.sh`:
```shell
# Edit these lines: {{{
AUDIODIRS=(
   "$HOME/audiodirs"
)
PLYLISTDIR="$HOME/audiodirs/plylists"
PLAYERCMD="nvlc --no-video --loop --random"
FINDERCMD="find ${AUDIODIRS[@]} -regextype posix-extended -regex "'.*(mp3|mp4|wav|flac|m4a|mkv)'
# FINDERCMD="fdfind -I "'.*(mp3|mp4|wav|flac|m4a|mkv)'" ${AUDIODIRS[@]}"
# }}}
```

3. Rename `ply.sh` to `ply`, make it executable and put it somewhere in your `$PATH` variable.
```shell
$ cp ply.sh ply
$ chmod +x ply
$ mv ply /somewhere/in/your/PATH
```
