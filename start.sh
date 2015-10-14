#!/bin/sh

root=~/prod/calendaruat

export PORT=8012


forever start --workingDir ${root} -a -l calendaruat.log /usr/bin/npm start