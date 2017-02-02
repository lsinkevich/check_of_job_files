#!/bin/bash

export SOURCE_PATH=/home/mila/Desktop/example
export RESULT_PATH=/home/mila/Desktop/result
export SEL_FILE=$RESULT_PATH/selection.txt
export TRF_FILE=$RESULT_PATH/transformation.txt
export RES_FILE=$RESULT_PATH/result.txt

echo > $SEL_FILE
echo > $RES_FILE

find $SOURCE_PATH -type f | while read FILENAME; do 
  #searching and processing of ENV files
  cat `find $SOURCE_PATH -name  "*.env"` | grep -E 'export' | sed 's/export//g' | sed 's/ //g' | sed 's/\$//g' >> $SEL_FILE
  
  #processing of an other file
  cat $FILENAME | grep -E 'export' | sed 's/export//g' | sed 's/ //g' | sed 's/\$//g' >> $SEL_FILE

  echo > $TRF_FILE  
  num=$(grep -o '\{' $SEL_FILE| wc -w)
  echo $FILENAME >> $RES_FILE
  echo 'Used files:' >> $RES_FILE
  cat $FILENAME | sed 's/=/ = /g'| sed 's/>/ > /g'| awk '{for(k=1;k<=NF;k++){print $k}}' | grep -E '\.' | grep -v '\$' | grep -v '\%' | grep -v '\$.' | grep -v '\.$' >> $RES_FILE

  #processing of the checklist
  while [ `echo $num` -ne 0 ]
  do

    #STR - the operating line, VAL, VAL1 - the operating value, VAL2 - the line for replacing
    export STR=$(cat $SEL_FILE | grep -E '\{' | sed -n 1p)
    export VAL=$(echo $STR | grep -o -P '(?<={).*?(?=})')	
    export VAL1=$(echo "{$VAL}")
    export VAL2=$(cat $SEL_FILE | grep -E `echo $VAL`= | sed 's|.*=||')   
    sed "s@`echo $VAL1`@`echo $VAL2`@" $SEL_FILE > $TRF_FILE
    
    num=$(( $num - 1 ))
    cat $TRF_FILE > $SEL_FILE
  done

  cat $SEL_FILE | sed 's/=/ = /g'| awk '{for(k=1;k<=NF;k++){print $k}}' | grep -E '\.' > $TRF_FILE
  cat $TRF_FILE >> $RES_FILE
  echo >> $RES_FILE
  rm $SEL_FILE
  rm $TRF_FILE
done

