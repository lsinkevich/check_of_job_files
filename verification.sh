#!/bin/bash

export SOURCE_PATH=/home/mila/Desktop/example
export RESULT_PATH=/home/mila/Desktop/result
export SEL_FILE=$RESULT_PATH/selection.txt
export RES_FILE=$RESULT_PATH/result.txt

echo > $RES_FILE

find $SOURCE_PATH -type f | while read FILENAME; do 
  #checklist
  cat $FILENAME | sed 's/=/ = /g'| sed 's/>/ > /g'| awk '{for(k=1;k<=NF;k++){print $k}}' | grep -E '\.' | grep -v '\$' | grep -v '\%' | grep -v '\$.' | grep -v '\.$' > $SEL_FILE   

  #check
  echo $FILENAME >> $RES_FILE
  num=$(cat $SEL_FILE | wc -w)
  if [ `echo $num` -gt 0 ]; then
    echo "Used files:" >> $RES_FILE
    while read p; do
      cd $SOURCE_PATH
      if [ ! -f "$p" ]; then 
	echo "$p - the file is not found" >> $RES_FILE
      else
        echo "$p - the correct file" >> $RES_FILE	  
        chmod +x $p
      fi
    done < $SEL_FILE
  fi

  echo >> $RES_FILE
  rm $SEL_FILE
done
