#!/usr/bin/env bash

AUDIODIRS=(
    "$HOME/Music"
    "$HOME/Music/plylists"
)
PLYLISTDIR="$HOME/Music/plylists"
PLAYERCMD="nvlc --no-video --loop --random"
FINDERCMD="find ${AUDIODIRS[@]} -regextype posix-extended -regex "'.*(mp3|mp4|wav|flac|m4a|mkv)'
# FINDERCMD="fdfind -I "'.*(mp3|mp4|wav|flac|m4a|mkv)'" ${AUDIODIRS[@]}"


show_help() {
    cat << _EOF_
Usage: ply [OPTIONS]

Options:
    -l, --list        list contents of current DEFAULT playlist
    -b, --build       build DEFAULT playlist
    -s, --save        save DEFAULT playlist
    -c, --chose       choose from saved playlists
_EOF_
}

die() {
    echo "$1"
    exit 1
}

AUDIODIRS=( "${AUDIODIRS[@]/$PLYLISTDIR/}" )
plylist="$PLYLISTDIR/plylist-default.m3u"
FZFCMD=(fzf -m --height=100 -d '^.*/' --with-nth=2 --prompt 'Add_to_plylist:')

if [ -n "$1" ]; then
    while :; do
        case $1 in
            -l|--list)
                echo "Default plylist:"
                cat "$plylist" | while read line; do echo " - "$(basename "$line"); done
                exit
                ;;
            -b|--build)
                # plstr=$($FINDERCMD ${AUDIODIRS[@]} | shuf | $FZFCMD)
                plstr=$($FINDERCMD | shuf | ${FZFCMD[@]})
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
                tmpstr=$(find "$PLYLISTDIR" -type f -name "plylist-*.m3u" | fzf -d '^.*/plylist-' --with-nth=2 --preview-window=right:65 --preview 'cat {} | while read line; do basename "$line"; done')
                [[ -z "$tmpstr" ]] && die "Canceled." || plylist=$tmpstr
                break
                ;;
            *)
                show_help
                exit
                ;;
        esac
        shift
    done
fi

$PLAYERCMD $plylist 2>/dev/null
exit
