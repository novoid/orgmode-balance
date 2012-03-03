#!/bin/bash

## this is a more or less quick hack that analyzes Org-mode files and
## gives feedback on how I am doing today (or at a given day):
## lists: closed items, created items and items still due
## The metrics are clearly subjective and should be improved

#FILEPATTERN="*(org|archive)"         ## which files to search in
FILEPATTERN="*"         ## which files to search in
ORGMODEDIR="${HOME}/share/all/org-mode/"  ## where org-mode files life
bldgrn='\e[1;32m'  ## from https://wiki.archlinux.org/index.php/Color_Bash_Prompt
bldred='\e[1;31m'  ## and http://tldp.org/LDP/abs/html/colorizing.html ... works with "bash on Linux"
txtgrn='\e[0;32m'  ## does *not* work with zsh or "bash on OS X"
txtred='\e[0;31m' 
txtwht='\e[0;37m'
IWhite='\e[0;97m'
BIWhite='\e[1;97m'

if [ "${1}x" = "x" ]; then
    ## set day to today
    DAY=`date +%Y-%m-%d`
else
    ## using $1 as daystamp
    DAY="${1}"
    ## FIXXME: add check, if $1 is a valid daystamp
fi

cd "${ORGMODEDIR}"
created_and_still_open=`egrep -B 3 ":CREATED: .${DAY}" ${FILEPATTERN} | egrep "\* (NEXT|TODO|STARTED|WAITING)"`
closed=`egrep -B 1 "CLOSED: .${DAY}" ${FILEPATTERN} | egrep "\* DONE"`
deadlinetoday=`egrep -B 1 "DEADLINE: .${DAY}" ${FILEPATTERN} | egrep "\* (NEXT|TODO|STARTED|WAITING)"`

if [ "${created_and_still_open}x" = "x" ]; then
    numcreated_and_still_open="0"
else
    numcreated_and_still_open=`echo "${created_and_still_open}" | wc -l`
fi

if [ "${closed}x" = "x" ]; then
    numclosed="0"
else
    numclosed=`echo "${closed}" | wc -l`
fi

if [ "${deadlinetoday}x" = "x" ]; then
    numdeadlinetoday="0"
else
    numdeadlinetoday=`echo "${deadlinetoday}" | wc -l`
fi

#echo "DEBUG:  numcreated_and_still_open [$numcreated_and_still_open]  numclosed [$numclosed]  numdeadlinetoday [$numdeadlinetoday]"

sum=$(($numcreated_and_still_open-$numclosed))

echo
echo -e ${BIWhite}"    ----===   ${DAY}   ===----"
echo
if [ "${created_and_still_open}x" != "x" ]; then
    echo -e ${BIWhite}"  created (& still_open):"
    echo -e ${txtred}"${created_and_still_open}"
    echo
fi
if [ "${closed}x" != "x" ]; then
    echo -e ${BIWhite}"  closed:"
    echo -e ${txtgrn}"${closed}"
    echo
fi
echo
echo -ne ${BIWhite}"      ${numcreated_and_still_open} created (& still open)  -  ${numclosed} done  ="

## generating the motivation messages
if [ "${sum}" -lt 1 ]; then
    echo -e ${bldgrn}"  ${sum}  sum"
    echo
    echo -e ${bldgrn}"  Congratulations!  Not more tasks generated than solved!"
else
    echo -e ${bldred}"  ${sum}  sum"
    echo
    echo -e ${bldred}"  Sorry, you still have to solve ${sum} issues to get even!"
fi
echo 

if [ "${numdeadlinetoday}" -gt 0 ]; then
    echo
    echo -en ${BIWhite}"      Still "
    echo -en ${bldred}${numdeadlinetoday}" deadline"
    if [ "${numdeadlinetoday}" -gt 1 ]; then
	echo -en ${bldred}"s"
    fi
    echo -e ${BIWhite}" due tough! "
    echo
fi

#end