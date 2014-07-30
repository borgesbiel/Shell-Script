#!/bin/bash
##################################################################################################################################
# Autor:     Gabriel Oliveira																	   																																 #	
# Data:      09/01/2012																		   									 																										 #
# Descricao: Processa Extracao RETORNO - CASAS BAHIA - usando o beb617.															                         							 #
##################################################################################################################################
#                                                                                                                                #
#                                  <<<<<       shell_cb_sai_retorno_beb617.ksh       >>>>>                                  #
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
   echo "Uso shell_cb_sai_retorno_beb617.ksh AAAAMMDD"
   exit 1
fi

DT_PROC_AA=`expr substr $1 1 4 `
DT_PROC_MM=`expr substr $1 5 2 `
DT_PROC_DD=`expr substr $1 7 2 `

DIR_DATA_LOG=D${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}
DATA=${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}

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
export LOGCARGA=${CCS_HOME}/log/${DIR_DATA_LOG}/cb_sai_retorno_${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}_${HOR}${MIN}${SEG}.log
export LOGCARGABAD=${CCS_HOME}/log/${DIR_DATA_LOG}/cb_sai_retorno_${DT_PROC_AA}${DT_PROC_MM}${DT_PROC_DD}_${HOR}${MIN}${SEG}.bad
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

WriteMessage "===========================<< shell_cb_sai_retorno_beb617.ksh >>=============================="
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
#EXTRACAO
##########################################################################################################################################
		
WriteMessage "EXECUTANDO PROCESSO BEB617 - RETORNO"

$CCS_BIN/beb617 -lR1DAQ030 -pretorno -etxt -s$CCS_HOME/tmp/${DIR_DATA_LOG}/out/ -d >> ${LOGCARGA} 2>&1

if [ -f ${LOGCARGA} ]; then
	ret=`cat ${LOGCARGA} | grep "Processo finalizado" | wc -l`
	if [ $ret = 0 ]; then
		WriteMessage "ERROR ${LOGCARGA} - PROCESSO BEB617 - RETORNO"
		error "Fim do processamento com erro"
		exit -1
	fi
else
	WriteMessage "ERROR NAO ENCONTRADO LOG ${ARQLOG} - PROCESSO BEB617 - RETORNO"
	error "Fim do processamento com erro"
	exit -1
fi

##########################################################################################################################################
#BUSCA DATA DO MOVIMENTO
##########################################################################################################################################

DTMOV=$( 
		echo "set feed off
		set pages 0
		select to_char(ifxdate,'YYYYMMDD') from dual;
		exit
		"  | sqlplus -s $CYBERCONNECT
		)	

										 
#############################################################################################################################
# Validacao da execucao do Processo de Extracao de Retorno
#############################################################################################################################

DIR=${CCS_HOME}/tmp/${DIR_DATA_LOG}/out

cd $DIR
	
	if [ ! -d ${DIR}/ArqSaida/ ] 
	then 
		echo "criando diretório ${DIR}/ArqSaida/"
		mkdir ArqSaida/
	fi	


	export QTD_ARQ_SAI=`ls -1 retorno_R1DAQ030_?_.txt 2>/dev/null | wc -l`
	
	if test $QTD_ARQ_SAI -gt 0
	   then 
	   	WriteMessage "Arquivo de Saida GERADO COM SUCESSO - RETORNO PARA VIA VAREJO -  BEB617"
				else 
					WriteMessage "Arquivo de Saida NAO GERADO - RETORNO PARA VIA VAREJO-  BEB617"
	fi
	 
			
		############################
		#Gerando o header e trailer#	
		############################           
		
		WriteMessage "EXECUTANDO PROCESSO de Geração de Header e Trailer."
		
		cd $DIR
			
		ret=`ls *retorno*.txt | wc -l`
		
		if [ $ret -eq 0 ]; then
			echo " Nao foram gerados arquivos de saida."
			WriteMessage " Nao foram gerados arquivos de saida."
		else
			
			ls -l *retorno*.txt | grep ^- | awk '{print $9}' > arqs 
				
		for FILE in `cat ./arqs`
		do
		
			#Remove a primeira linha    
			sed '1d'  $FILE > tmp.txt
	  		mv tmp.txt $FILE	
			
			###############################################
			#Conta o numero de linhas por tipo de registro#	
			############################################### 
			
			QTRG02=`grep "^02" $FILE | wc -l | awk '{printf("%09d" ,$1)}'`
			QTRG03=`grep "^03" $FILE | wc -l | awk '{printf("%09d" ,$1)}'`
			QTRG04=`grep "^04" $FILE | wc -l | awk '{printf("%09d" ,$1)}'`
			QTRG05=`grep "^05" $FILE | wc -l | awk '{printf("%09d" ,$1)}'`
			QTRG06=`grep "^06" $FILE | wc -l | awk '{printf("%09d" ,$1)}'`
			QTRG07=`grep "^07" $FILE | wc -l | awk '{printf("%09d" ,$1)}'`			
						

			#Ordena pelo tipo do registro
			sort -n -k1.1,1.2 $FILE > $FILE.sorted
			mv 	$FILE.sorted $FILE

			#Remove a primeira linha    
			sed '1d'  $FILE > tmp.txt
	  		mv tmp.txt $FILE

			#Conta total de registros 	
			if [ `head -1 $FILE | wc -c $FILE | awk '{print $1}'` -ne 0  ]; then			
			#Tirando Rodape em branco do arquivo
    		#sed '$d'  $FILE > tmp.txt
	  		#mv tmp.txt $FILE
			CONT=`wc -l $FILE | awk '{printf("%010d" ,$1+2)}'`			    	
			else
		 	CONT=`echo 2 | awk '{printf("%08d" , $1)}'`	
			fi
			
			#Trailer					
			BRANCOST1="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			BRANCOST2="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
			TRAILER="99000000001${QTRG02}${QTRG03}${QTRG04}${QTRG05}${QTRG06}${QTRG07}${BRANCOST1}${CONT}${BRANCOST2}"
			

			#Header
			BRANCOSH="HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
			HEADER="01${DTMOV}${HORA}BBCYBERAAAAAAAAAAAAAAAAAAAAAAAAA${BRANCOSH}"			
			
			NOME_NOVO="${DATA}_Retorno_ViaVarejo_out.txt"			
			
			#Inserindo o Header na primeira linha do arquivo				
			awk 'BEGIN{print "'${HEADER}'"}1' $FILE > tmp.txt			
			mv tmp.txt $FILE
			
			#Inserindo o Trailer na ultima linha do arquivo				
			awk '1;END{print "'${TRAILER}'"}' $FILE > tmp.txt			
			mv tmp.txt $FILE
			
			#Troca para Brancos Header
			sed "s/HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH/                                                                                                                                                                                                                                                                                                                        /" $FILE > tmp.txt	
			mv tmp.txt $FILE
			
		  #Troca para Brancos Trailer
			sed "s/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/                                                                                                    /" $FILE > tmp.txt	
			mv tmp.txt $FILE
			sed "s/YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY/                                                                                                                                                                                         /" $FILE > tmp.txt	
			mv tmp.txt $FILE
			
			#Troca para Brancos Header
			sed "s/BB/  /" $FILE > tmp.txt	
			mv tmp.txt $FILE
			
			#Troca para Brancos Header
			sed "s/AAAAAAAAAAAAAAAAAAAAAAAAA/                         /" $FILE > tmp.txt	
			mv tmp.txt $FILE

				
			mv $FILE ${DIR}/ArqSaida/$NOME_NOVO
		
		done
	 fi
	 
rm arqs

##########################################################################################################################################
# Retorna informando sucesso.
##########################################################################################################################################
WriteMessage "Fim normal de processamento."
WriteMessage "----------------------------"	
