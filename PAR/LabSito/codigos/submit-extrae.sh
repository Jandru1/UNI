#!/bin/bash

#SBATCH --job-name=submit-extrae.sh
#SBATCH -D .
#SBATCH --output=submit-extrae.sh.o%j
#SBATCH --error=submit-extrae.sh.e%j

USAGE="\n USAGE: ./submit-extrae.sh prog solver numthreads \n
        prog        -> Program name\n
        solver      -> 0: Jacobi; 1: Gauss-Seidel\n
        numthreads  -> Number of threads in parallel execution\n"

if (test $# -lt 3 || test $# -gt 3)
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

make $1

if (test $2 = 0)
then
        SOLVER="jacobi"
else
    if (test $2 = 1)
    then
        SOLVER="gausseidel"
    else
        SOLVER=""
    fi
fi

export OMP_NUM_THREADS=$3

export LD_PRELOAD=${EXTRAE_HOME}/lib/libomptrace.so
./$1 test.dat -n 10 -a $2 -o heat-extrae-${SOLVER}.ppm
unset LD_PRELOAD

mpi2prv -f TRACE.mpits -o $1-${SOLVER}-$3-${HOST}.prv -e $1 -paraver
rm -rf  TRACE.mpits set-0 >& /dev/null

