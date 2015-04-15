#!/bin/bash

if [ $# -eq 3 ]
then
	elenco=`ls $2`
	if [ `ls $2 | wc -l` -eq 0 ]
	then
		echo
		echo "La directory indicata non contiene file"
		exit 1
	fi
	if [ $? -gt 0 ]
	then
		echo "Directory non trovata"
		exit 2
	fi
	directory=`ls $3`
	if [ $? -gt 0 ]
	then
		echo "Directory di destinazione non esistente!"
		exit 3
	fi
	if [ $1 == 'completo' ]
	then
		ultima_data=0
	else
		if [ $1 == 'incrementale' ]
		then
			directory=`ls $3`
			ultima_data=0
			for i in $directory
			do
				n=`stat -c %Y $3/$i`
				if [ $n -gt $ultima_data ]
				then
					ultima_data=$n
				fi
			done
			if [ $ultima_data -eq 0 ]
			then
				echo "Non e' stato eseguito nessun backup precedentemente"
				exit 4
			fi
		else
			if [ $1 == 'differenziale' ]
			then
				ultima_data=0
				for i in $directory
				do 
					if [ ${i:13:8} == 'completo' ]
					then
						n=`stat -c %Y $3/$i`
						if [ $n -gt $ultima_data ]
						then
							ultima_data=$n
						fi	
					fi
				done
				if [ $ultima_data -eq 0 ]
				then
					echo "Backup completo non trovato!"
					exit 5
				fi
			else
				echo "Tipo di backup non esistente!"
				exit 6
			fi
		fi	
	fi
	
	filecopiare=`ls $2`	
	cartelledacopiare=`date +%Y%m%d%H%M`
	copiati=0
	dacopiare=0
	errori=0
	mkdir $3/${direcotrycopy}_$1
	for i in $filecopiare
	do
		data_file=`stat -c %Y $2/$i`
		if [ $data_file -gt $ultima_data ]
		then
			dacopiare=$((dacopiare+1))
			cp $2/$i $3/${directorycopy}_$1
			if [ $? -gt 0 ]
			then
				echo "Impossibile fare il backup dell'elemento: *$i" >&2"*"
				errori=$((errori+1))
			else
				echo "Backup dell'elemento: *$i* effettuato"
				copiati=$((copiati+1))
			fi
		fi
	done
	if [ $dacopiare -eq 0 ]
	then
		echo "Nessun file cambiato dall'ultimo backup!"
		rmdir $3/${direcotrycopy}_$1
		exit 7
	else
		echo "Backup Completato correttamente"
		if [ $errori -eq 0 ]
		then
			exit 0
		else
			exit 8
		fi
	fi

else
	echo "Reinserire i dati "
	echo "Tipo di bakup, directory sorgente e direcotry di destinazione"
	exit 9
fi	