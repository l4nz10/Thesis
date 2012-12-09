#!/bin/bash
#
#########################################################################
# Thesis Stat, a simple bash script that displays information about     #
# the status of the thesis developed with my template.                  #
# Author: n0on3 <a.n0on3@gmail.com> - http://www.n0on3.net              #
#########################################################################
#

#------------------------ SETTINGS
#
COUNT_CHAR_AND_PAGES='Y'
COUNT_ACRONYMS='Y'
COUNT_BIB_ENTRIES='Y'
COUNT_BIB_UNUSED_ENTRIES='Y'
DISPLAY_SVN_REPORT='N'
CHECK_FOR_FILES_NOT_UNDER_VC='N'
#
#---------------------------------
CONTENT_PATH="."
BIB_FILE="contents/other/references.bib"
NAA="(comment|anyotherthingyoudonotwanttobegreppedbythe@expr)"
exclude_from_svn='(\.svn|DS_store|Roman)'
char_per_page=1500
LL=94;  # <----- Lines width
SEP='+' # <----- Separator
#
#------------------------ COLORS 
#
RED="\033[31;40m"; GRE="\033[32;40m"; YEL="\033[33;40m"; BLU="\033[34;40m";
MAG="\033[35;40m"; CYA="\033[36;40m"; WHI="\033[37;40m"; SUP=`echo $GRE`
#
#------------------------ FUNCTIONS
#
function print_n { N="$2"; while [ $N -gt 0 ]; do echo -n $1; N=$((N-1)); done; }
#
function maketext_ { echo -en "$2"; set -f; echo -n "$1"; set +f; }
#
function write_ { echo -en " $BLU$SEP "; echo -en $1; echo -en " $BLU$SEP "; echo -en "$WHI"; }
#
function line { write_ `maketext_ $(print_n $SEP $LL) "$BLU"`; echo; }
#
function emptyline { write_ `maketext_ $(print_n '-' $LL) "$CYA"`; echo; }
#
function header { echo
 TITLE='  ~ Thesis Stats ~  '; line
 TITLE_LENGTH=`echo "$TITLE" | wc -c | awk '{print $1}'`
 maketext_ " $SEP " "$BLU"; 
 maketext_ $(print_n '.' $(((1+($LL-$TITLE_LENGTH)/2)))) $CYA; 
 maketext_ "$TITLE" $YEL; 
 maketext_ $(print_n '.' $(((1+($LL-$TITLE_LENGTH)/2)))) $CYA; 
 maketext_ " $SEP " "$BLU"; echo; line; emptyline;
}
#
function count_char_and_pages {
 char=`find $CONTENT_PATH/contents/ | \
 grep '.tex$' | egrep -v "(appendix|settings|dedication|thesis\.tex|frontpage|glossary)" | \
 xargs cat | grep -v ^% | grep -v ^$ | sed 's/\\\[a-z]*//g' | sed 's/{//g' | sed 's/}//g' | wc -c | awk '{print $1}'`
 pages=`echo $((char/$char_per_page))`; message="Char & Pages count: $char chars, more or less $pages pages "
 length=`echo $message | wc -c | awk '{print $1}'`
 report="`maketext_ "Char & Pages count: " "$SUP"``maketext_ "$char" "$RED"`\
 `maketext_ "chars, more or less " "$SUP"``maketext_ "$pages" "$RED"``maketext_ " pages" "$SUP"``maketext_ '' "$CYA"`"
 padding=" `print_n '.' $(($LL-$length))`"
 write_ "$report$padding"; echo; emptyline
}
#
function acrocount {
 ACR=`cat $CONTENT_PATH/contents/other/glossary.tex | egrep '^\\\\' | wc -l | awk '{print $1}'`
 m="Defined Acronyms And Glossary Entries: "; message="$m $ACR"; length=`echo $message | wc -c | awk '{print $1}'`
 report="`maketext_ "$m" "$SUP"``maketext_ "$ACR" "$RED"``maketext_ '' "$CYA"`"
 padding=" `print_n '.' $(($LL-$length))`"
 write_ "$report$padding"; echo; emptyline
}
#
function bib_entries {
 bibn=`cat $BIB_FILE | grep -v comment | grep ^@ | wc -l | awk '{print $1}'`
 m="Defined Citations / BIB Entries: "; message="$m $bibn"; length=`echo $message | wc -c | awk '{print $1}'`
 report="`maketext_ "$m" "$SUP"``maketext_ "$bibn" "$RED"``maketext_ '' "$CYA"`"
 padding=" `print_n '.' $(($LL-$length))`"
 write_ "$report$padding"; echo; emptyline
}
#
function bib_cit_unused {
 message="Bib entries check: "; length=`echo $message | wc -c | awk '{print $1}'`
 message=`maketext_ "$message" "$SUP"`; padding=" `print_n '.' $(($LL-$length))`"
 padding=`maketext_ $padding $CYA`
 write_ "$message$padding";echo; emptyline
 find $CONTENT_PATH -type f | grep -v 'svn' | xargs egrep -o "cite{[^}]*}" | \
 sed 's/tex:/ /g' | awk '{print $NF}' | sort | uniq | sed 's/cite{\(.*\)}/\1/g' > /tmp/citations
 cat $BIB_FILE | grep @ | egrep -iv $NAA | tr '{' ' ' | tr ',' ' ' | awk '{print $NF}' | sort > /tmp/bibentries
 ALL_CITED=1;
 while read cit; do grep $cit < /tmp/citations &>/dev/null; 
 if [ $? == 1 ]; then
  message="bibtex entry \"$cit\" is NOT used!"; length=`echo $message | wc -c | awk '{print $1}'`
  report="`maketext_ "bibtex entry '" "$SUP"``maketext_ "$cit" "$RED"``maketext_ "' is NOT used!" "$SUP"``maketext_ ' ' "$CYA"`"
  padding="`print_n '.' $(($LL-$length))`"
  write_ "$report$padding"; ALL_CITED=0; echo
 fi; done < /tmp/bibentries
 if [ $ALL_CITED -eq 1 ];then
 message="All bib entries are used!"; length=`echo $message | wc -c | awk '{print $1}'`;
 message=`maketext_ "$message" "$SUP"``maketext_ ' ' "$CYA"`
 padding="`print_n '.' $(($LL-$length))`"; write_ "$message$padding"; echo; fi
 emptyline;
}
#
function svn_report {
 last_revision=`svn info | grep ^Revision: | awk '{print $2}'`
 last_date=`svn info | grep "Last Changed Date:" | awk '{print $5" "$4}' | sed 's/-/ /g' | awk '{print $4"/"$3" "$1}'`
 last_hour=`echo $last_date | awk '{print $2}'`; last_date=`echo $last_date | awk '{print $1}'`
 m="SVN last revision: "; n=", committed on "; message="$m$last_revision$n$last_date at $last_hour"; length=`echo $message | wc -c | awk '{print $1}'`
 report="`maketext_ "$m" "$SUP"``maketext_ "$last_revision" "$RED"``maketext_ "$n" "$SUP"``maketext_ "$last_date" "$RED"`\
 `maketext_ "at " "$SUP"``maketext_ "$last_hour" "$RED"``maketext_ ' ' "$CYA"`"
 padding="`print_n '.' $(($LL-$length))`";write_ "$report$padding"; echo; emptyline;
}
#
function check_files_not_in_svn {
 message="Version control check: "; length=`echo $message | wc -c | awk '{print $1}'`
 message=`maketext_ "$message" "$SUP"`; padding=" `print_n '.' $(($LL-$length))`"
 padding=`maketext_ $padding $CYA`
 write_ "$message$padding";echo; emptyline
 ALL_UNDER_VC=1
 for i in `find . -type f | egrep -iv "$exclude_from_svn"`;
 	do svn info $i &>/dev/null; 
	if [ $? -eq 1 ]; then 
	m1=`maketext_ "$i" "$RED"`; 
	message="is NOT under version control!";
	m2=`maketext_ "$message" "$SUP"`
	length=`echo "$i $message" | wc -c | awk '{print $1}'`; padding=" `print_n '.' $(($LL-$length))`"
	padding=`maketext_ $padding $CYA`; write_ "$m1 $m2 $padding"; echo; emptyline;  ALL_UNDER_VC=0; fi 
 done; if [ $ALL_UNDER_VC -eq 1 ];then
 	message="All files in folder are under version control ;)";
 	m=`maketext_ "All files in folder are under version control ;)" "$SUP"`;
	length=`echo $message | wc -c | awk '{print $1}'`; padding=" `print_n '.' $(($LL-$length))`"
	padding=`maketext_ $padding $CYA`; write_ "$m $padding"; echo; emptyline;
 fi;
}
#------------------------ OPERATIONS
#
header 
if [ $COUNT_CHAR_AND_PAGES == "Y" ]; then count_char_and_pages; fi
if [ $COUNT_ACRONYMS       == "Y" ]; then acrocount; fi
if [ $COUNT_BIB_ENTRIES == "Y" ]; then bib_entries; fi
if [ $COUNT_BIB_UNUSED_ENTRIES == "Y" ]; then bib_cit_unused; fi
if [ $DISPLAY_SVN_REPORT == "Y" ]; then svn_report; fi
if [ $CHECK_FOR_FILES_NOT_UNDER_VC == "Y" ]; then check_files_not_in_svn; fi
line
echo
#
#
#
