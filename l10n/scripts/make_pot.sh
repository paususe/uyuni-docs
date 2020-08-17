#!/bin/bash
# You need po4a > 0.54, see https://github.com/mquinson/po4a/releases
# There is no need of system-wide installation of po4a
# Usage: PERLLIB=/path/to/po4a/lib make_pot.sh
# you may set following variables
# SRCDIR root of the documentation repository
# POTDIR place where to create the pot

####################################
# INITILIZE VARIABLES
####################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# root of the documentation repository
SRCDIR_MODULE="$SCRIPT_DIR/../../modules"

# place where to create the pot files
if [ -z "$POTDIR" ] ; then
    POTDIR="$SCRIPT_DIR/../pot/"
fi

# place where the po files are
if [ -z "$PO_DIR" ] ; then
	PO_DIR="$SCRIPT_DIR/../po/"
fi

####################################
# TEST IF IT CAN WORK
####################################

if [ ! -d "$SRCDIR_MODULE" ] ; then
    echo "Error, please check that SRCDIR match to the root of the documentation repository"
    echo "You specified modules are in $SRCDIR_MODULE"
    exit 1
fi


####################################
# HANDLE articles and pages
####################################

while IFS= read -r -d '' file
do
    filewithoutprefix=${file##$SRCDIR_MODULE/}
    basename=$(basename -s .adoc "$file")
    dirname=$(dirname "$file")
    path="${dirname#$SRCDIR_MODULE/}"

    if [ "$dirname" = "$SRCDIR_MODULE" ]; then
        potname=$basename.pot
    else
        potname=$path/$basename.pot
        mkdir -p "$POTDIR/$path"
    fi

    po4a-gettextize \
        --format asciidoc \
        --master "$file" \
        --master-charset "UTF-8" \
        --po "$POTDIR/$potname"

    for lang in $(ls "$PO_DIR" ); do

        po_file="$PO_DIR/$lang/${potname%.pot}.po"

        # po4a-updatepo would be angry otherwise
        # Only required for po4a < 0.58, and it didn't work very well anyway
        #sed -i 's/Content-Type: text\/plain; charset=CHARSET/Content-Type: text\/plain; charset=UTF-8/g' "$po_file"

        if ! po4a-updatepo \
            --format asciidoc \
            --master "$file" \
            --master-charset "UTF-8" \
            --po "$po_file" ; then
        echo ""
        echo "Error updating $lang PO file $po_file for: $adoc_file"

        fi
    done

done <   <(find -L "$SRCDIR_MODULE" -name "*.adoc" -print0)

echo ""
echo "#REMOVE TEMPORARY FILES"

for lang in $(ls "$PO_DIR" ); do
    for module in $(ls modules); do
        if [ -e $SRCDIR_MODULE/$module/assets/images ]; then
            mkdir -p $PO_DIR/$lang/$module/assets/images
            rsync -u --inplace -a --delete $SRCDIR_MODULE/$module/assets/* $PO_DIR/$lang/$module/assets/
        fi
    done
    
	rm -f "$PO_DIR/$lang/contact/"*.po~
	rm -f "$PO_DIR/$lang/articles/"*.po~
done
