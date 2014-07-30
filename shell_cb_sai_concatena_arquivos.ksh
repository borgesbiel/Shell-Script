#!/bin/bash
##################################################################################################################################
# Autor:     Gabriel Oliveira																	   																																 #	
# Data:      09/01/2012																		   									 																										 #
# Descricao: Concatena arquivos de saida.															                         							 #
##################################################################################################################################
#                                                                                                                                #
#                                  <<<<<       shell_cb_sai_concatena_arquivos.ksh       >>>>>                                  #
#                                                                                                                                #
# $1 - Data de referencia (formato AAAAMMDD)                                                                                     #
# $2 - Arquivo a ser carregado																									 #
##################################################################################################################################
# Historico de Alterações                                                                                                        #
# Data          Autor                      Descrição                                                                             #
# -----------   ------------------------   -----------------------                                                               #
##################################################################################################################################

#* -----------------------------------------------------------------------------------------------------------------------------*#
#* Configura as variaveis de ambiente necessarias para execucao.                                                                *#
#* -----------------------------------------------------------------------------------------------------------------------------*#

NumArgs=$#
if [ "$NumArgs" -ne 1 ]; then
   echo "Uso shell_cb_sai_concatena_arquivos.ksh AAAAMMDD"
   exit 1
fi

DT_PROC_AA=`expr substr $1 1 4 `
DT_PROC_MM=`expr substr $1 5 2 `
DT_PROC_DD=`expr substr $1 7 2 `

DIR_DATA_LOG=D${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}
DATA=${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}
DATA2=${DT_PROC_MM}${DT_PROC_DD}${DT_PROC_AA}

HOR=`date +%H`
MIN=`date +%M`
SEG=`date +%S`

HORA=`date +%H%M%S`

# VARIAVEIS DE AMBIENTE GLOBAL
. $CCS_SCR/CASASBAHIA_VARIAVEIS.ksh ${DT_PROC_DD} ${DT_PROC_MM} ${DT_PROC_AA}

# SET IFXDATE
. $CCS_SCR/shell_cb_ifxdate_inicia.ksh ${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}


DIR_LOG=${CCS_HOME}/log/${DIR_DATA_LOG}


# VARIAVEIS COM NOME DO ARQUIVO DE LOG
export LOGCARGA=${CCS_HOME}/log/${DIR_DATA_LOG}/cb_sai_concatena_arquivos_${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}_${HOR}${MIN}${SEG}.log
export LOGCARGABAD=${CCS_HOME}/log/${DIR_DATA_LOG}/cb_sai_concatena_arquivos_${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}_${HOR}${MIN}${SEG}.bad
export SCRNAME=`basename $0|cut -f1 -d'.'`
export NLS_LANG=SPANISH_MEXICO.WE8ISO8859P1
export NLS_DATE_FORMAT="dd-mon-yyyy hh24:mi:ss"
export SECONDS_SLEEP=2

#*----- Uso geral *#
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

WriteMessage "===========================<< shell_cb_sai_concatena_arquivos.ksh >>=============================="
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


										 
##########################################################################################################################################     	
#Inicio do Processo Principal                                                                                                                            	
##########################################################################################################################################

DIR=${CCS_HOME}/tmp/${DIR_DATA_LOG}/out

cd $DIR
	
	if [ ! -d ${DIR}/ArqSaida/ ] 
	then 
		echo "criando diretório ${DIR}/ArqSaida/"
		mkdir ArqSaida/
	fi	
	
	if [ ! -d ${DIR}/ArqSaida/Concat/ ] 
	then 
		cd ${DIR}/ArqSaida/
		echo "criando diretório ${DIR}/ArqSaida/Concat/"
		mkdir Concat/
	fi	

	if [ ! -d ${DIR}/ArqOrigem/ ] 
	then 
		cd ${DIR}	
		echo "criando diretório ${DIR}/ArqOrigem/"
		mkdir ArqOrigem/
	fi	
	
#Verifica quais agencias estao na pasta
cd ${DIR}/ArqSaida/
`ls -l *.txt | cut -d'_' -f2 |cut -d'.' -f1 > agencia.txt`

##########################################################################################################################################
# Loop Principal
##########################################################################################################################################
while read LINE         
do
AGENCIA_ATUAL=$LINE

##########################################################################################################################################
# Processamento Principal
##########################################################################################################################################
		
		ls -l *_${AGENCIA_ATUAL}.txt | grep ^- | awk '{print $9}' > arqs 
	
    for FILE in `cat ./arqs`
    do 
        
				cat $FILE >> ${DATA}_remessa_consolidada_${AGENCIA_ATUAL}_out.txt

		done
		rm arqs
		
		#remove brancos
		sed '/^$/d' ${DATA}_remessa_consolidada_${AGENCIA_ATUAL}_out.txt > tmp.txt
		mv tmp.txt ${DATA}_remessa_consolidada_${AGENCIA_ATUAL}_out.txt
		
		#move o arquivo concatenado	
		mv ${DATA}_remessa_consolidada_${AGENCIA_ATUAL}_out.txt ${DIR}/ArqSaida/Concat/
		

done < agencia.txt #Fim Loop Principal
rm agencia.txt


##########################################################################################################################################
# Gera HEADER e TRAILER
##########################################################################################################################################
       
		
WriteMessage "EXECUTANDO PROCESSO DE GERAÇÃO DE HEADER E TRAILER."

cd ${DIR}/ArqSaida/Concat

	ret=`ls *remessa_consolidada*.txt | wc -l`
		
	if [ $ret -eq 0 ]; then
		echo " Nao foram gerados arquivos de saida."
		WriteMessage " Nao foram gerados arquivos de saida."
	else
		
		ls -l *remessa_consolidada*.txt | grep ^- | awk '{print $9}' > arqs 
			
	for FILE in `cat ./arqs`
	do
			###############################################
			#Conta o numero de linhas por tipo de registro#	
			############################################### 
			
			QTRG01=`grep "^01" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG02=`grep "^02" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG03=`grep "^03" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG04=`grep "^04" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG05=`grep "^05" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG06=`grep "^06" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`			
			QTRG07=`grep "^07" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG08=`grep "^08" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG09=`grep "^09" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG10=`grep "^10" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG11=`grep "^11" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`
			QTRG12=`grep "^12" $FILE | wc -l | awk '{printf("%08d" ,$1)}'`			
			                                                   
			CONT=`wc -l $FILE | awk '{printf("%08d" ,$1+2)}'`			
			HEADER="HCYBERREMESSA!ASSESSORIA${DATA2}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"			
			TRAILER="T${DATA2}${CONT}${QTRG01}${QTRG02}${QTRG03}${QTRG04}${QTRG05}${QTRG06}${QTRG07}${QTRG08}${QTRG09}${QTRG10}${QTRG11}${QTRG12}!!!!!"
			
			#Inserindo o Header na primeira linha do arquivo				
			awk 'BEGIN{print "'${HEADER}'"}1' $FILE > tmp.txt			
			mv tmp.txt $FILE
			
			#Inserindo o Trailer na ultima linha do arquivo				
			awk '1;END{print "'${TRAILER}'"}' $FILE > tmp.txt			
			mv tmp.txt $FILE
			
			#Troca para Brancos		
			sed 's/!/ /g' $FILE > tmp.txt			
			mv tmp.txt $FILE
			

	done
fi	
rm arqs
#move e remove os arquivos concatenados e trabalhados	
cp ${DIR}/ArqSaida/??_*.txt ${DIR}/ArqOrigem/
cp ${DIR}/ArqSaida/Concat/*.* ${DIR}/ArqSaida/

##########################################################################################################################################
# Retorna informando sucesso.
##########################################################################################################################################
WriteMessage "Fim normal de processamento."
WriteMessage "----------------------------"	
