#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <cstring>
#include <algorithm>
#include "../inc/hmm.h"

#define MAX_HMM_NUM 10

using namespace std;

static void print_usage();
static double _delta[MAX_SEQ][MAX_STATE];
double viterbi(HMM* hmm,char* line);

int main(int argc, char** argv) {
    if(argc!=4){
        printf("expected 3 parameters but %d given.",argc-1);
        print_usage();
        return 0;
    }
    char line[MAX_LINE];
    HMM hmms[MAX_HMM_NUM];
    char* modellist = argv[1];
    char* test_file = argv[2];
    char* result_file = argv[3];
    int n = load_models(modellist, hmms, MAX_HMM_NUM);
    FILE *fin = open_or_die(test_file, "r");
    FILE *fout = open_or_die(result_file, "w");
    memset(_delta, 0, sizeof(_delta));
    double tmp; //record current prob
    while (fscanf(fin, "%s", line) > 0) {
        double prob = -1;
        size_t ID = 0;
        for(size_t i = 0; i < n; ++i){
            tmp = viterbi(&hmms[i],line);
            if(tmp > prob){
                prob = tmp;
                ID = i;
            }
        }
        fprintf(fout, "%s %g\n", hmms[ID].model_name, prob);
    }

    fclose(fin);
    fclose(fout);
    return 0;
}
static void print_usage()
{
    printf("usage: ./test <models_list_path> <seq_path> <output_result_path>");
}
double viterbi(HMM* hmm, char* line)
{
    int state_num = hmm->state_num;
    int T = strlen(line);
    //initialization
    for(int s = 0; s < state_num; ++s)
        _delta[0][s] = hmm->initial[s] * hmm->observation[line[0]-'A'][s];
    //recursion
    for(int t = 1; t < T; t++) {
        for(int s = 0; s < state_num; ++s) {
            double max_elem = 0;
            for(int j = 0; j < state_num; j++){
                max_elem = max(max_elem, _delta[t-1][j] * hmm->transition[j][s]);
            }
            _delta[t][s] = max_elem * hmm->observation[line[t]-'A'][s];
        }
    }
    //termination
    double ret_prob = 0;
    for(size_t i=0;i<state_num;i++){
        ret_prob = max(ret_prob,_delta[T-1][i]);
    }
    return ret_prob;
}


