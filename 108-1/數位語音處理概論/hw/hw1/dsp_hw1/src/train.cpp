#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <vector>
#include <array>
#include "../inc/hmm.h"

using namespace std;

static double _alpha[MAX_SEQ][MAX_STATE];
static double _beta[MAX_SEQ][MAX_STATE];
static double _epsilon[MAX_SEQ][MAX_STATE][MAX_STATE];
static double _init_update[MAX_STATE];//update pi
static double _sum_gamma[MAX_STATE][MAX_OBSERV];
static double _sum_gamma_tail[MAX_STATE];
static double _sum_epsilon[MAX_STATE][MAX_STATE];
static void print_usage();
static void init();
void trainHMM(HMM* hmm,char* seq_model,size_t iter);
void train(HMM* hmm, vector<size_t*> seqs,int T);
void get_alpha(HMM *hmm, size_t* seq,int T);
void get_beta(HMM *hmm, size_t* seq,int T);
void get_gamma(HMM *hmm, size_t* seq,int T);
void get_eps(HMM *hmm, size_t* seq,int T);
void update_param(HMM *hmm, int n);

int main(int argc,char**argv)
{
    if(argc!=5){
        printf("expected 4 parameters but %d given.");
        print_usage();
        return 0;
    }
    HMM hmm;
    size_t iter = atoi(argv[1]);
    char* model_init = argv[2];
    char* seq_model = argv[3];
    char* output_model = argv[4];
    //initialize model
    loadHMM(&hmm,model_init);
    //train
    trainHMM(&hmm,seq_model,iter);
    //output result
    FILE *fout = fopen(output_model, "w");
    dumpHMM(fout, &hmm);
    fclose(fout);
    return 0;
    
}

static void print_usage()
{
    printf("usage: ./train <iter> <model_init_path> <seq_path> <output_model_path>");
}
static void init() {
    //reset before every iteration
    memset(_sum_gamma, 0, sizeof(_sum_gamma));
    memset(_sum_gamma_tail, 0, sizeof(_sum_gamma_tail));
    memset(_sum_epsilon, 0, sizeof(_sum_epsilon));
    memset(_init_update, 0, sizeof(_init_update));
}
void trainHMM(HMM* hmm, char* seq_model, size_t iter)
{
    char seq[MAX_SEQ];
    FILE *fp = open_or_die(seq_model, "r");
    vector<size_t*> seqs;
    int n_seqs = 0, T=0;
    while(fgets(seq, MAX_SEQ, fp) !=NULL) {
        T = strlen(seq)-1;
        size_t* seq_i = new size_t [MAX_SEQ];
        for(int t = 0; t < T; ++t){
            seq_i[t] = seq[t]-'A';
        }
        seqs.push_back(seq_i);
        n_seqs++;
    }
    //training process
    for(int i=0;i<iter;i++){
        //per iter
        init();
        train(hmm,seqs,T);
        update_param(hmm,n_seqs);
    }
}
void train(HMM* hmm, vector<size_t*> seqs, int T)
{
    for (int i = 0; i < seqs.size(); i++){
        size_t* line = seqs[i];
        get_alpha(hmm,line,T);
        get_beta(hmm,line,T);
        get_gamma(hmm,line,T);
        get_eps(hmm,line,T);
    }
}
void get_alpha(HMM *hmm, size_t* seq,int T)
{
    int state_num = hmm->state_num;
    //initial
    for(int s = 0; s < state_num; ++s){
        _alpha[0][s] = hmm->initial[s] * hmm->observation[seq[0]][s];
    }
    // induction
    for(int t = 1; t < T; t++){
        for(int s = 0; s < state_num; ++s){
            _alpha[t][s] = 0;
            for(int ps = 0; ps < state_num; ps++){
                _alpha[t][s] += _alpha[t-1][ps] * hmm->transition[ps][s];
            }
            _alpha[t][s] *= hmm->observation[seq[t]][s];
        }
    }
}
void get_beta(HMM *hmm, size_t* seq, int T)
{
    int state_num = hmm->state_num;
    //initial
    for(int s=0;s<state_num;s++){
        _beta[T-1][s] = 1;
    }
    //induction
    for(int t = T-2; t >= 0; --t){
        for(int s = 0; s < state_num; ++s){
            _beta[t][s] = 0;
            for(int ns = 0; ns < state_num; ns++){
                _beta[t][s] += hmm->transition[s][ns] * hmm->observation[seq[t+1]][ns] * _beta[t+1][ns];
            }
        }
    }
}
void get_gamma(HMM *hmm, size_t* seq,int T)
{
    //gamma
    int state_num = hmm->state_num;
    for(int t = 0; t < T; ++t){
        double sum = 0;
        for(int i = 0; i < state_num; i++) { sum += _alpha[t][i] * _beta[t][i]; }
        for(int i = 0; i < state_num; i++) {
            double gamma = _alpha[t][i] * _beta[t][i] / sum;
            if (t==0){
                _init_update[i] += gamma;
            }
            if (t==T-1){
                _sum_gamma_tail[i] += gamma;
            }
            _sum_gamma[i][seq[t]] += gamma;
        }
    }
    
}
void get_eps(HMM *hmm, size_t* seq,int T)
{
    //epsilon
    int state_num = hmm->state_num;
    for (int t = 0; t < T-1; ++t) {
        double sum_eps = 0;
        for (int i = 0; i < state_num; ++i){
            for (int j = 0; j < state_num; ++j) {
                sum_eps += _alpha[t][i] *
                hmm->transition[i][j] *
                hmm->observation[seq[t+1]][j] *
                _beta[t+1][j];
            }
        }
        for (int i = 0; i < state_num; ++i){
            for (int j = 0; j < state_num; ++j){
                _epsilon[t][i][j] = _alpha[t][i] *
                hmm->transition[i][j] *
                hmm->observation[seq[t+1]][j] *
                _beta[t+1][j]/sum_eps;
                _sum_epsilon[i][j] += _epsilon[t][i][j];
            }
        }
    }
    
}
void update_param(HMM *hmm,int n)
{
    //***** update parameters *****
    //update pi
    int state_num = hmm->state_num;
    int observ_num = hmm->observ_num;
    for (int i = 0; i < state_num; ++i){
        hmm->initial[i] = _init_update[i]/n;
    }
    //update transition A
    for (int i = 0; i < state_num; ++i) {
        double temp = 0.0;
        for (int j = 0; j < observ_num; ++j){
            temp += _sum_gamma[i][j];
        }
        temp -= _sum_gamma_tail[i];
        for (int j = 0; j < state_num; ++j){
            hmm->transition[i][j] = _sum_epsilon[i][j] / temp;
        }
    }
    //update observation B
    for (int i = 0; i < state_num; ++i) {
        double temp = 0.0;
        for (int j = 0; j < observ_num; ++j){
            temp += _sum_gamma[i][j];
        }
        for (int j = 0; j < observ_num; ++j){
            hmm->observation[j][i] = _sum_gamma[i][j] / temp;
        }
    }
}
