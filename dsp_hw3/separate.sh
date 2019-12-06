iter=1
while [[ $iter -le 10 ]]; do
	perl separator_big5.pl test_data/$iter.txt > seg_test_data/$iter.txt
	iter=$[$iter+1];
done
