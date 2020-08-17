#!/bin/bash -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -o errexit

for DIR in $SCRIPT_DIR/../* ; do
	if ! test -d "$DIR" ; then
		continue
	fi
	for WLPO in $DIR/*.po ; do
		# basename
		LNG=${WLPO##*/}
		LNG=${LNG%.po}
		for POT in `find $DIR -name "*.pot"` ; do
			# Replce string pot by $LNG/po
			ADPO=${POT/pot/po/$LNG}
			echo \# ADPO1 = $ADPO
			# .pot => .po
			ADPO=${ADPO%t}
			echo \# ADPO2 = $ADPO
			
			ADPODIR=${ADPO%/*}
			
			echo \# ADAPODIR=$ADPODIR
			
			mkdir -p "$ADPODIR"
			echo -n "${ADPO#../}"
			msgmerge --force-po --no-fuzzy-matching "$WLPO" "$POT" -o "$ADPO".tmp1
			msgattrib --force-po --no-obsolete "$ADPO".tmp1 -o "$ADPO".tmp2
			if test -f "$ADPO" ; then
				# In case of conflict, weblate translation takes precedence.
				# Better would be --use-newest, which is not in the upstream yet.
				msgcat --force-po --use-first "$ADPO".tmp2 "$ADPO" -o "$ADPO"
			else
				mv "$ADPO".tmp2 "$ADPO"
			fi
			rm "$ADPO".tmp*
		done
	done
done
