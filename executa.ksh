#!/bin/sh
date >>/cyberapp/rcvry/log/D"$(cat dataCiclo)"/executaOut.txt
date >>/cyberapp/rcvry/log/D"$(cat dataCiclo)"/executaErr.txt

cd /cyberapp/rcvry/shells/ 1>>/cyberapp/rcvry/log/D"$(cat dataCiclo)"/executaOut.txt 2>> /cyberapp/rcvry/log/D"$(cat dataCiclo)"/executaErr.txt &
. /cyberapp/rcvry/shells/$1 "$(cat dataCiclo)" 1>>/cyberapp/rcvry/log/D"$(cat dataCiclo)"/executaOut.txt 2>> /cyberapp/rcvry/log/D"$(cat dataCiclo)"/executaErr.txt &
exit

