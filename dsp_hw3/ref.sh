#!/bin/bash

iter=1
while [[ $iter -le 10 ]]; do
	echo iter$iter
	(set -x; disambig -text test_data_sep/$iter.txt -map ZhuYin-Big5.map -lm bigram.lm -order 2 > ref_output/$iter.txt)
	(set -x; ./mydisambig test_data_sep/$iter.txt ZhuYin-Big5.map bigram.lm result/$iter.txt)
	iter=$[$iter+1];
done
