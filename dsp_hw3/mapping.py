import sys
import os
import collections

def main():
	fin = sys.argv[1]
	fout = sys.argv[2]
	dic = collections.defaultdict(list)
	with open(fin, 'r', encoding='BIG5-HKSCS') as f:
		for line in f:
			line = line.split(' ')
			char = line[0]
			zhuins = line[1].split('/')
			for item in zhuins:
				dic[item[0]].append(char)
			dic[char] = [char]

	with open(fout, 'w', encoding='BIG5-HKSCS') as f:
		for k, v in sorted(dic.items()):
			f.write(' '.join([k] + v) + '\n')

if __name__ == "__main__":
    main()

