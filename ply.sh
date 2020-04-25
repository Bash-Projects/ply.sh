#!/usr/bin/env bash

# Edit these lines: {{{
AUDIODIRS=(
#    "$HOME/audiodirs"
    "$HOME/Music"
)
#PLYLISTDIR="$HOME/audiodirs/plylists"
PLYLISTDIR="$HOME/Music/plylists"
PLAYERCMD="nvlc --no-video --loop --random"
FINDERCMD="find ${AUDIODIRS[@]} -regextype posix-extended -regex "'.*(mp3|mp4|wav|flac|m4a|mkv)'
# FINDERCMD="fdfind -I "'.*(mp3|mp4|wav|flac|m4a|mkv)'" ${AUDIODIRS[@]}"
# }}}


show_help() {
    cat << _EOF_
Usage: ply [OPTIONS]

Options:
    -l, --list        list contents of current DEFAULT playlist
    -b, --build       build DEFAULT playlist
    -s, --save        save DEFAULT playlist
    -c, --choose      choose from saved playlists
    -a, --append      append entries to chosen playlist
    -r, --remove      remove entries from chosen playlist
_EOF_
}

die() {
    echo "$1"
    exit 1
}

AUDIODIRS=( "${AUDIODIRS[@]/$PLYLISTDIR/}" )
plylist="$PLYLISTDIR/plylist-default.m3u"

[[ ! -d "$PLYLISTDIR" ]] && die "$PLYLISTDIR not found."

if [ -n "$1" ]; then
    while :; do
        case $1 in
            -l|--list)
                [[ ! -f "$plylist" ]] && die "You haven't built any plylist. Build with ply -b"
                echo "Default plylist:"
                cat "$plylist" | while read line; do echo " - "$(basename "$line"); done
                exit
                ;;
            -b|--build)
                # plstr=$($FINDERCMD ${AUDIODIRS[@]} | shuf | $FZFCMD)
                plstr=$($FINDERCMD | shuf | fzf -m --height=100 -d '^.*/' --with-nth=2 --prompt="Add to plylist: ")
                [[ -z "$plstr" ]] && die "Canceled." || echo "$plstr" > "$plylist"
                exit
                ;;
            -s|--save)
                cat "$plylist" | while read line; do echo " - "$(basename "$line"); done
                echo -n "Save default plylist as: "
                read input_str
                [[ -z "$input_str" ]] && die "Canceled." || cp "$plylist" "${plylist/default.m3u/${input_str}.m3u}"
                exit
                ;;
            -c|--choose)
                tmpstr=$(find "$PLYLISTDIR" -type f -name "plylist-*.m3u" | fzf -d '^.*/plylist-' --prompt="Choose plylist: " --with-nth=2 --preview 'cat {} | while read line; do basename "$line"; done')
                [[ -z "$tmpstr" ]] && die "Canceled." || plylist="$tmpstr"
                break
                ;;
            -d|--delete)
                tmpstr=$(find "$PLYLISTDIR" -type f ! -name "plylist-default.m3u" -name "plylist-*.m3u" | fzf -m -d '^.*/plylist-' --prompt="Delete plylist: " --with-nth=2 --preview 'cat {} | while read line; do basename "$line"; done')
                [[ -z "$tmpstr" ]] && die "Canceled." || set -f; ORIFS=$IFS; IFS=$'\n'; rm ${tmpstr[@]}; IFS=$ORIFS; set +f
                exit
                ;;
            -a|--append)
                tmpstr=$(find "$PLYLISTDIR" -type f -name "plylist-*.m3u" | fzf -d '^.*/plylist-' --prompt="Choose plylist to append: " --with-nth=2 --preview 'cat {} | while read line; do basename "$line"; done')
                [[ -z "$tmpstr" ]] && die "Canceled." || chosenplylist="$tmpstr"
                plstr=$($FINDERCMD | shuf | fzf -m --height=100 -d '^.*/' --with-nth=2 --prompt="Append to ${chosenplylist/*-/}: " --preview 'cat '"$chosenplylist"' | while read line; do basename "$line"; done')
                [[ -z "$plstr" ]] && die "Canceled." || echo "$plstr" >> "$chosenplylist"
                exit
                ;;
            -r|--remove)
                tmpstr=$(find "$PLYLISTDIR" -type f -name "plylist-*.m3u" | fzf -d '^.*/plylist-' --prompt="Plylist to remove entries: " --with-nth=2 --preview 'cat {} | while read line; do basename "$line"; done')
                [[ -z "$tmpstr" ]] && die "Canceled." || chosenplylist="$tmpstr"
                cat "$chosenplylist" | fzf -m -d '^.*/' --with-nth=2 --prompt="Which entries to remove: " | while read line
                do
                    sed -i '/'"${line//\//\\\/}"'/d' "$chosenplylist"
                done
                exit
                ;;
            *)
                show_help
                exit
                ;;
        esac
        shift
    done
fi

[[ ! -f "$plylist" ]] && die "You haven't built any plylist. Build with ply -b"

$PLAYERCMD "$plylist" 2>/dev/null
exit
