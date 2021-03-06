#!/bin/bash
# gather logs generated by "make [dist]check"
# this also limits log size so that buildbot does not abort
# Copyright (C) 2020 by Rainer Gerhards, released under ASL 2.0

show_log() {
	if grep -q ":test-result: FAIL" "$1"; then
		printf "\nFAIL: ${1%%.trs} \
		########################################################\
		################################\n\n"
		logfile="${1%%trs}log"
		if [ -f "$logfile" ]; then
			lines="$(wc -l < $logfile)"
			if (( lines > 4000 )); then
				ls -l $logfile
				printf 'file is very large (%d lines), showing parts\n' $lines
				head -n 2000 < "$logfile"
				printf '\n\n... snip ...\n\n'
				tail -n 2000 < "$logfile"
			else
				cat "$logfile"
			fi
		else
			printf 'log FILE MISSING!\n'
		fi
	fi
}

append_summary() {
	echo file: $1 # emit file name just in case we have multiple!
	head -n12 "$1"
}

export -f show_log
export -f append_summary

############################## MAIN ENTRY POINT ##############################
printf 'find failing tests\n'
rm -f failed-tests.log

find . -name "*.trs" -exec  bash -c 'show_log "$1" >> failed-tests.log' _ {} \;

if [ -f failed-tests.log ]; then
	# show summary stats so that we know how many failed
	find . -name test-suite.log -exec bash -c 'append_summary "$1" >>failed-tests.log' _ {} \;
fi
