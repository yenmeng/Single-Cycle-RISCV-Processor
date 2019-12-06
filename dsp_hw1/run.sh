#!/bin/bash -ex
make
MIN=0
MAX=1000
file=curve

if [ -f $file ] ; then
  rm $file
fi

for ((i = MIN; i <= MAX; i+=10)); do
  for ((j = 1; j <= 5; j++)); do 
    ./train $i model_init.txt data/train_seq_0"$j".txt model_0"$j".txt
  done
  ./test modellist.txt data/test_seq.txt result.txt
  python3 acc.py data/test_lbl.txt result.txt >> process.txt
done

make clean
