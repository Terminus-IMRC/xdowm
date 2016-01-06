#!/usr/bin/env bash

usage() {
	echo "Usage: $0 [URL]"
}

# This is from iPhone 5. You can use other mobile UAs.
UA='Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) CriOS/37.0.2062.60 Mobile/11D257 Safari/9537.53'

if test "$#" -ne 1; then
	echo "error: invalid arguments"
	usage
	exit 1
fi

URL="$1"

VIDEOID=$(echo "$URL" | cut -d/ -f4)
VIDEOTITLE=$(echo "$URL" | cut -d/ -f5-)

if test -z "$VIDEOID" -o -z "$VIDEOTITLE"; then
	echo "error: invalid format of input URL"
	usage
	exit 1
fi

OUT="${VIDEOID}-${VIDEOTITLE}.mp4"

TMP=$(mktemp)

wget -U "$UA" "$URL" -O "$TMP" -q

RET=$?
if test "$RET" -ne 0; then
	echo "error: wget returned $RET"
	usage
	exit 1
fi

# The latter .mp4 URL (the former in this case because sed matches .mp4 in reversed order) seems to be better in resolution.
URL=$(tr -d '\n\t ' <"$TMP" \
	| sed -n \
		-e ":loop" \
		-e "	h" \
		-e "	s/^\(.*\)'\([^']*\.mp4[^']*\)'\(.*\)$/\2/p" \
		-e "	g" \
		-e "	s/^\(.*\)'\([^']*\.mp4[^']*\)'\(.*\)$/\1\3/g" \
		-e "/'[^']*\.mp4[^']*'/b loop" \
	| head -n 1)

rm -f "$TMP"

wget "$URL" -O "$OUT"
