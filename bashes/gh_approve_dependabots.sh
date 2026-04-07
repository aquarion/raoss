#!/bin/bash

SLEEPFOR=10;

gh pr list |\
	grep dependabot |\
	cut  -f1 |\
	while read PR; 
	do 
		echo "Approving and merging PR #$PR";
		LOOP_COUNT=0;
		OUT=1;
			while [ $OUT -ne 0 ]; do
			gh pr review "$PR" --approve; 
			gh pr merge "$PR" --auto --merge

			OUT=$?;
			LOOP_COUNT=$((LOOP_COUNT+1));
			if [ $LOOP_COUNT -gt 5 ]; then
				echo "Failed to approve and merge PR #$PR after 5 attempts. Skipping.";
				break;
			fi
			
			for _seq in $(seq 1 $SLEEPFOR); do
				echo -n ".";
				sleep 1;
			done;
			echo "!";

		done;
	done;

