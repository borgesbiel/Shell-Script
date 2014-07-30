#!/bin/bash
#!/bin/bash
A=1
while [ $A -eq 1 ]
do
  CP=`ps -ef | grep cb | wc -l`                  
  echo "executando"
  if [ $CP -eq 0 ]; then
    echo "terminado"
    break
  fi
  sleep 3
  echo "terminado"
done


