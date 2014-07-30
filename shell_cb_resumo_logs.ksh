#!/bin/bash
#########################################################################################################################
# Autor:     Gabriel Oliveira
# Data:      06/05/2013
# Descricao: Gera resumo de logs
#########################################################################################################################
#
# Historico de Alteracoes
# 
# Data          Autor                      Descricao
# -----------   ------------------------   ---------------------------------------------------
#* ------------------------------------------------------------------------------------------------------------------- *#
# Configura as variaveis de ambiente necessarias para execucao.
#########################################################################################################################

NumArgs=$#
if [ "$NumArgs" -ne 1 ]; then
   echo "Uso shell_cb_resumo_logs.ksh AAAAMMDD"
   exit 1
fi
DATA_PROC=$1
DT_PROC_AA=`expr substr $1 1 4 `
DT_PROC_MM=`expr substr $1 5 2 `
DT_PROC_DD=`expr substr $1 7 2 `

DIR_DATA_LOG=D${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}
DATASIS=`date +%Y%m%d`
HOR=`date +%H`
MIN=`date +%M`
SEG=`date +%S`

HORA=`date +%H%M`

# VARIAVEIS DE AMBIENTE GLOBAL
. $CCS_SCR/CASASBAHIA_VARIAVEIS.ksh ${DT_PROC_DD} ${DT_PROC_MM} ${DT_PROC_AA}

# SET IFXDATE
. $CCS_SCR/shell_cb_ifxdate_inicia.ksh ${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}


DIR_LOG=${CCS_HOME}/log/${DIR_DATA_LOG}


# VARIAVEIS COM NOME DO ARQUIVO DE LOG
export LOGCARGA=${CCS_HOME}/log/${DIR_DATA_LOG}/cb_proc_resumo_logs_${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}_${HOR}${MIN}${SEG}.log
export LOGCARGABAD=${CCS_HOME}/log/${DIR_DATA_LOG}/cb_proc_resumo_logs_${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}_${HOR}${MIN}${SEG}.bad
export SCRNAME=`basename $0|cut -f1 -d'.'`
export NLS_LANG=SPANISH_MEXICO.WE8ISO8859P1
export NLS_DATE_FORMAT="dd-mon-yyyy hh24:mi:ss"
export SECONDS_SLEEP=2


WriteMessage ()
{
    echo "`date '+%d/%m/%Y %H:%M:%S'` $1" >>"$LOGCARGA"
}

error ()
{
    echo "`date '+%d/%m/%Y %H:%M:%S'` $1, Processamento CANCELADO." >> "$LOGCARGA"
}

abort ()
{
    error "$1"
    exit -1
}

#Criando diretorios
if [ ! -d $DIR_LOG ]; then 
    WriteMessage "Diretorio de log \"$DIR_LOG\" nao existente."
    WriteMessage "Criando diretorio $DIR_LOG"
    mkdir $DIR_LOG
    
fi 

if [ ! -d $TMP_PROC ]; then
    WriteMessage "Diretorio de tmp \"$TMP_PROC\" nao existente."
    WriteMessage "Criando diretorio $TMP_PROC"
    mkdir $TMP_PROC
    chmod 777 $TMP_PROC
fi

WriteMessage "===========================<< shell_cb_resumo_logs.ksh >>=============================="
WriteMessage "Configuracao das variaveis de ambiente concluida"
WriteMessage "Referencia (DIA) : ${DT_PROC_DD}"
WriteMessage "Referencia (MES) : ${DT_PROC_MM}" 
WriteMessage "Referencia (ANO) : ${DT_PROC_AA}"
WriteMessage "Referencia (DATA): ${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}"
WriteMessage "CCS_SCR         : $CCS_SCR"
WriteMessage "CCS_HOME         : $CCS_HOME"
WriteMessage "CCS_BIN          : $CCS_BIN"
WriteMessage "CTL              : $CTL"
WriteMessage "ORACLE_HOME      : $ORACLE_HOME"
WriteMessage "ORACLE_SID       : $ORACLE_SID"
WriteMessage "NLS_LANG         : $NLS_LANG"
WriteMessage "NLS_DATE_FORMAT  : $NLS_DATE_FORMAT"
WriteMessage "======================================================================================"

if [ ! -w $LOG_PROC -o ! -x $LOG_PROC ]; then
    echo "Sem permissao de escrita no Diretorio \"$LOG_PROC\" !"
    echo "Fim do processamento com erro"
    exit -1  
fi

if [ ! -d $OUT ]; then
    mkdir $OUT
    chmod 777 $OUT
    WriteMessage "Foi criado o Diretorio $OUT."
fi

if [ ! -d $SAIDA ]; then
    mkdir $SAIDA
    chmod 777 $SAIDA
    WriteMessage "Foi criado o Diretorio $SAIDA"
fi

if [ ! -w $TMP_PROC -o ! -x $TMP_PROC ]; then
    WriteMessage "Sem permissao de escrita no Diretorio \"$TMP_PROC\" !"
    abort "Fim do processamento com erro" 
fi


#############################################################################################################################

WriteMessage "INICIO DO PROCESSAMENTO"

#############################################################################################################################

diro=`pwd`
cd ${CCS_HOME}/log/${DIR_DATA_LOG}/

#cria lista de logs
`ls -1tr cb*.log > /cyberapp/rcvry/shells/lista_logs.txt`

#loop logs
while read LINE         
do
		INICIO=`head -1 $LINE | cut -d'=' -f1 | awk '{printf("%-8s %-8s",$1,$2)}'`
		
		FIM=`tail -1 $LINE |  cut -d'-' -f1 | awk '{printf("%-8s %-8s",$1,$2)}'`
		
		echo "$LINE,$INICIO,$FIM" >> /cyberapp/rcvry/shells/resumo_old.txt							 	
				
			
done < /cyberapp/rcvry/shells/lista_logs.txt #Fim Loop Principal

#alinha os nomes e registros
awk '{ printf "%-55s%-10s %-10s\n",$1,$2,$3}' FS=\, /cyberapp/rcvry/shells/resumo_old.txt >> ${CCS_HOME}/log/${DIR_DATA_LOG}/resumo_logs_${DATA_PROC}.txt  2>/dev/null

#ordena por hora
sort -n -k1.67,1.69 -k1.70,1.72 ${CCS_HOME}/log/${DIR_DATA_LOG}/resumo_logs_${DATA_PROC}.txt > ${CCS_HOME}/log/${DIR_DATA_LOG}/resumo_logs_${DATA_PROC}.sorted
mv ${CCS_HOME}/log/${DIR_DATA_LOG}/resumo_logs_${DATA_PROC}.sorted ${CCS_HOME}/log/${DIR_DATA_LOG}/resumo_logs_${DATA_PROC}.txt

#limpa tmps
rm /cyberapp/rcvry/shells/lista_logs.txt /cyberapp/rcvry/shells/resumo_old.txt

cd $diro

#############################################################################################################################
# Retorna informando sucesso.
#############################################################################################################################
WriteMessage "----------------------------"
WriteMessage "Fim normal de processamento."
WriteMessage "----------------------------"

