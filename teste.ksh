#!/bin/bash
DATA=$1

/cyberapp/rcvry/shells/shell_cb_ent_carga_beb545.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_man_cad_beb545.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_man_fin_beb545.ksh 

wait

/cyberapp/rcvry/shells/shell_cb_ent_mercadoria_beb645.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_servico_beb645.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_bloqcob_beb645.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_neg_beb645.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_taxas_beb645.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_pagamentos_beb045.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_pagto_atu.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_pagto_beb003.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_ent_baixa_beb045.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_dmsubset.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_dmdays.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_parcelas.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_label_1_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_label_2_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_label_3_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_q6_aviso_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_q1_decisao_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_arrasto_q1.ksh $DATA

wait


/cyberapp/rcvry/shells/shell_cb_proc_q3_acordo_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_q4_negativacao_beb115.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_distrib_beb116.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_arrasto_agn.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_gestor_beb137.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_fasecob.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_atual_perm.ksh $DATA


wait

/cyberapp/rcvry/shells/shell_cb_proc_desemp_beb610.ksh $DATA

wait

cyberapp/rcvry/shell_cb_proc_Atu_Pagto_beb611.ksh $DATA

wait

/cyberapp/rcvry/shells/shell_cb_proc_comissao_beb616.ksh $DATA


