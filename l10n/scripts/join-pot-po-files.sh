#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -o errexit

for DIR in $SCRIPT_DIR/../pot/* ; do
	if ! test -d "$DIR" ; then
		continue
	fi
	DOMAIN=${DIR##*/}
	echo "$DOMAIN/$DOMAIN.pot"
	mkdir -p "$DOMAIN"
	msgcat --use-first `find "$DIR" -name "*.pot"` -o "$DOMAIN/$DOMAIN".pot
	for LNGDIR in $SCRIPT_DIR/../po/*/"$DOMAIN" ; do
		if ! test -d "$LNGDIR" ; then
			continue
		fi
		LNG=${LNGDIR%/*}
		LNG=${LNG##*/}
		echo "$DOMAIN/$LNG.po"
		# In case of conflict, weblate translation takes precedence.
		# Better would be --use-newest, which is not in the upstream yet.
		if test -f "$DOMAIN/$LNG".po ; then
			msgcat --lang=$LNG --use-first "$DOMAIN/$LNG".po `find $SCRIPT_DIR/../po/$LNG/$DOMAIN -name "*.po"` -o "$DOMAIN/$LNG".po.new
		else
			msgcat --lang=$LNG --use-first `find $SCRIPT_DIR/../po/$LNG/$DOMAIN -name "*.po"` -o "$SCRIPT_DIR/../po/$LNG/$DOMAIN".po.new
		fi
		mv "$SCRIPT_DIR/../po/$LNG/$DOMAIN".po.new "$SCRIPT_DIR/../po/$LNG/$DOMAIN".po
	done
done
