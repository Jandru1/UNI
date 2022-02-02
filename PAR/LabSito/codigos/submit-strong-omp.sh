#!/bin/bash

#SBATCH --job-name=submit-strong-omp.sh
#SBATCH -D .
#SBATCH --output=submit-strong-omp.sh.o%j
#SBATCH --error=submit-strong-omp.sh.e%j

USAGE="\n USAGE: ./submit-strong-omp.sh solver \n
    solver      -> 0: Jacobi; 1: Gauss-Seidel\n"

if (test $# -lt 1 || test $# -gt 1)
then
        echo -e $USAGE
            exit 0
        fi

HOST=$(echo $HOSTNAME | cut -f 1 -d'.')

if (test "${HOST}" = "boada-1")
then
        echo "Use sbatch to execute this script"
        exit 0
fi

SEQ=heat
PROG=heat-omp
np_NMIN=1
np_NMAX=12
N=1

if (test $1 = 0)
then
    SOLVER="jacobi"
else
    if (test $1 = 1)
    then
        SOLVER="gausseidel"
    else
        SOLVER=""
    fi
fi

# Make sure that all binaries exist
make $SEQ
make $PROG

out=$PROG-${SOLVER}-strong.txt	# File where you save the execution results
aux=./tmp-${SOLVER}.txt     	# archivo auxiliar

outputpath=./elapsed.txt
outputpath2=./speedup.txt
rm -rf $outputpath 2> /dev/null
rm -rf $outputpath2 2> /dev/null

echo Executing $SEQ sequentially >> $out
elapsed=0  # Acumulacion del elapsed time de las N ejecuciones del programa
i=0        # Variable contador de repeticiones
while (test $i -lt $N)
	do
		echo $'\n' >> $out
        export OMP_NUM_THREADS=1
		/usr/bin/time --format=%e ./$SEQ test.dat -a $1 >> $out 2>$aux

		time=`cat $aux|tail -n 1`

		elapsed=`echo $elapsed + $time|bc`

		i=`expr $i + 1`
	done
echo $'\n' >> $out
echo -n ELAPSED TIME AVERAGE OF $N EXECUTIONS = >> $out
sequential=`echo $elapsed/$N|bc -l`
echo $sequential >> $out

i=0
PARS=$np_NMIN
while (test $PARS -le $np_NMAX)
do
	echo $'\n' >> $out
	echo -n Executing $PROG in parallel with $PARS threads >> $out
	elapsed=0  # Acumulacion del elapsed time de las N ejecuciones del programa

	while (test $i -lt $N)
		do
			echo $'\n' >> $out
            export OMP_NUM_THREADS=$PARS
			/usr/bin/time --format=%e ./$PROG test.dat -a $1 >> $out 2>$aux

			time=`cat $aux|tail -n 1`

			elapsed=`echo $elapsed + $time|bc`

			rm -f $aux
			i=`expr $i + 1`
		done

	echo $'\n' >> $out
	echo -n ELAPSED TIME AVERAGE OF $N EXECUTIONS = >> $out
    	average=`echo $elapsed/$N|bc -l`
    	result=`echo $sequential/$average|bc -l`
    	echo $average >> $out

	i=0

    	#output PARS i average en fichero elapsed time
	echo -n $PARS >> $outputpath
	echo -n "   " >> $outputpath
    	echo $average >> $outputpath

    	#output PARS i average en fichero speedup
	echo -n $PARS >> $outputpath2
	echo -n "   " >> $outputpath2
    	echo $result >> $outputpath2

    	#incrementa el parametre
	PARS=`expr $PARS + 1`
done

jgraph -P strong-omp.jgr >  $PROG-${SOLVER}-strong.ps
usuario=`whoami`
fecha=`date`
sed -i -e "s/UUU/$usuario/g" $PROG-${SOLVER}-strong.ps
sed -i -e "s/FFF/$fecha/g" $PROG-${SOLVER}-strong.ps
