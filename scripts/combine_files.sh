#!/bin/bash

tmpfile=$1
sample=$2
signalp=$3
apop=$4
targetp=$5
molw=$6


#printf "ID\tsignalp_pred\tsignalp_prob_sec\tsignalp_prob_other\tsignalp_cs_pos\tsignalp_\ttargetp_pred\ttargetp_notp\ttargetp_sp\ttargetp_mtp\ttargetp_ctp\ttargetp_lutp\ttargetp_cs_pos\tapop_pred\tapop_prob\tmol_weight[kDa]\ttmhmm_len\ttmhmm_expaa\ttmhmm_first60\ttmhmm_predhel\ttmhmm_top\tmol_weight_mature[kDa]\n" > $tmpfile
printf "ID\tsignalp_pred\tsignalp_prob_sec\tsignalp_prob_other\tsignalp_cs_pos\ttargetp_pred\ttargetp_notp\ttargetp_sp\ttargetp_mtp\ttargetp_ctp\ttargetp_lutp\ttargetp_cs_pos\tapop_pred\tapop_prob\tmol_weight[kDa]\n" > $tmpfile

tail -n +3 $signalp | sort -k1,1 > output/$sample/tmp_signalp.tsv
tail -n +3 $targetp | sort -k1,1 | cut -f2- > output/$sample/tmp_targetp.tsv
grep -v "|" $apop | head -n -11 | tail -n +2 | sort -k1,1 | cut -f2- > output/$sample/tmp_apop.tsv
tail -n +2 $molw | sort -k1,1 | cut -f2- > output/$sample/tmp_molw.tsv

paste output/$sample/tmp_signalp.tsv output/$sample/tmp_targetp.tsv output/$sample/tmp_apop.tsv output/$sample/tmp_molw.tsv >> $tmpfile
