#!/usr/bin/env fish
set JOURNAL_DIR "$HOME/wiki/journal"
set TODAY (date +"%Y-%m-%d")
set FILE_HEADER "# $(date "+%A, %B %d, %Y")"\n"## Todo: "\n"_________________________________________________________________________________"\n

set JOURNAL_FILE "$JOURNAL_DIR/$TODAY.md"
if not test -e $JOURNAL_FILE
    echo $FILE_HEADER > $JOURNAL_FILE 
end
