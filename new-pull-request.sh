#!/usr/bin/env bash
set -eu

TMP=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMP}; }
trap clean EXIT

randomword () {
	set -x
	local total randomn
	total=$(wc -l /usr/share/dict/words|cut -d " " -f1)
	randomn=$(jot -r 1 1 ${total})
	sed "${randomn}q;d" /usr/share/dict/words
}

word=$(randomword)
branch=pull-branch-${word}
git checkout -b $branch master

echo $word > html/random.txt

cat > ${TMP} <<EOF
Add random word $word

We used to think that bird is the word but the best word in the world is
$word

EOF


git add data/random.txt
git commit -F ${TMP} data/random.txt

hub pull-request -F ${TMP} -p -b master -l random

