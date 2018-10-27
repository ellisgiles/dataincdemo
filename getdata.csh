#!/bin/csh

if ($#argv > 1) then
        echo "Usage: $0 num"
        echo "Gets the first num (default 1000000) meta-data fields out of yfcc100m"
        goto done
endif

set n=1000000

if ($#argv == 1) then
	set n=$1
endif

head -$n yfcc100m_dataset | awk 'BEGIN { FS = "\t" } ; {print $8 " " $9 }' | sed 's/\-/ /g;s/[,\+\.]/ /g;s/\%../ /g;s/  */ /g;s/^ //g' | tr '[:upper:]' '[:lower:]' 

done:
