#include <cassert>
#include <algorithm>
#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <set>
#include <map>
#include "File.h"
#include "Prob.h"
#include "Ngram.h"
#include "Vocab.h"

using namespace std;
void print_usage(){
	cout<<"--------------------------------"<<endl;
	cout<<"usage: ./mydisambig $1 $2 $3 $4"<<endl;
	cout<<"$1 segemented file to be decoded"<<endl;
	cout<<"$2 ZhuYin-Big5 mapping"<<endl;
	cout<<"$3 language model"<<endl;
	cout<<"$4 output file"<<endl;
	cout<<"--------------------------------"<<endl;
}
double getBigramProb(const char* w1, const char* w2, Vocab& voc, Ngram& lm)
{
    VocabIndex wid1 = voc.getIndex(w1);
    VocabIndex wid2 = voc.getIndex(w2);
    
    if(wid1 == Vocab_None)  //OOV
        wid1 = voc.getIndex(Vocab_Unknown);
    if(wid2 == Vocab_None)  //OOV
        wid2 = voc.getIndex(Vocab_Unknown);
    
    VocabIndex context[] = { wid1, Vocab_None };
    return lm.wordProb( wid2, context);
}
void createMap(ifstream& mapfile, map<string, set<string> >& Map)
{
	string line;
	//ofstream fout("mapping.txt");
	while(getline(mapfile,line)){
		stringstream ss;
		ss<<line;
		string index;
		ss>>index;
		set<string> & curr = Map[index];
		//fout<<index<<" ";
		string word;
		while(ss>>word){
			//cout<<word.length()<<' ';
			curr.insert(word);
			//fout<<word<<' ';
		}
		//fout<<endl;
	}
	string sentence_end = "</s>";
    set<string> & end = Map[sentence_end];
    end.insert(sentence_end);
	//fout.close();
	mapfile.close();
}
void viterbi(string line, map<string, set<string> >& Map, Ngram& lm, Vocab& voc, ofstream& out)
{
	VocabString s[maxWordsPerLine];
	s[0] = Vocab_SentStart;
	char* buf = new char[line.length()+1];
	strcpy(buf,line.c_str());
	int count = Vocab::parseWords(buf, s+1, maxWordsPerLine);
	//cout<<count<<endl;
	s[count+1] = Vocab_SentEnd;
	count+=1;
	vector<vector<LogP> > delta(count);
	vector<vector<VocabString> > words(count);
	vector<vector<int> > backtrack(count);
	stringstream ss;
	ss<<line;	
	for(int i=0; i<count; i++){
        string word;
        if (i==count-1)
            word = "</s>";
        else
        	ss>>word;
		set<string>::iterator iter;
        for(iter=Map[word].begin();iter!=Map[word].end();++iter)
        {
            words[i].push_back((*iter).c_str());
            delta[i].push_back(LogP_Zero);
			backtrack[i].push_back(-1);
        }
		if(words[i].size() == 0 ){
			words[i].push_back(Vocab_Unknown);
			delta[i].push_back(LogP_Zero);
			backtrack[i].push_back(-1);
		}
	}
		
	//initial
	for(int i=0; i<delta[0].size(); i++){
        delta[0][i] = getBigramProb("<s>", words[0][i], voc, lm);
		//cout<<delta[0][i]<<endl;
        backtrack[0][i] = -1;
    }
	//recursion
	for(int i=1; i<delta.size(); i++) {
        for(int j=0; j<delta[i].size(); j++) {
            delta[i][j] = LogP_Zero;
            for(int k=0; k<delta[i-1].size(); k++)
            {
				LogP prob = getBigramProb(words[i-1][k], words[i][j], voc, lm) + delta[i-1][k];
				if( prob > delta[i][j] ) {
					//cout<<prob<<endl;
                   	delta[i][j] = prob;
                    backtrack[i][j] = k;
				}
            }
			//cout<<delta[i][j]<<"  "<<backtrack[i][j]<<endl;
        }		
    }
	//backtrack
	int b = 0;
  	VocabString ans[count];
  	for(int i = count-1; i >= 0; i--) {
    	ans[i] = words[i][b];
    	b = backtrack[i][b];
  	}
	out<<"<s> ";
	for(int i = 0; i < count; i++){
		//if(ans[i]=="<unk>") continue;
		out<<ans[i];
		if(i==count-1) out<<endl;
		else out<<' ';
	}
}
	
int main (int argc, char* argv[]) {
	if(argc!=5){
        printf("ERROR: expected 4 parameters but %d given.\n",argc-1);
        print_usage();
        exit(1);
    }
	int order = 2;
	Vocab vocab;
	Ngram lm(vocab, order);
	map<string, set<string> > Map;
	//declare files
	ifstream testfile(argv[1]);
	ifstream ZhuYinBig5Map(argv[2]);
	ofstream fout(argv[4]);
	//error handling
	if(!testfile || !ZhuYinBig5Map){
		if(!testfile)
			cerr << "ERROR: \""<<argv[1]<<"\" doesn't exist!\n";		
		if(!ZhuYinBig5Map)
			cerr << "ERROR: \""<<argv[2]<<"\" doesn't exist!\n"; 		
		exit(1);
	}
	// read LM 
	File lmfile(argv[3], "r");
  	lm.read(lmfile);
  	lmfile.close();
	// make Map
	createMap(ZhuYinBig5Map,Map);
	// read test data
	File test_data(argv[1],"r");
	string line;
	while(getline(testfile,line)){
		//fout<<line<<endl;
		viterbi(line,Map,lm,vocab,fout);	
	}
	test_data.close();
	return 0;
}
