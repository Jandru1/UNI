USAGE="\n USAGE: ./run_tareador.sh prog \n
        prog        -> Tareador program name\n
        solver      -> 0: Jacobi; 1: Gauss-Seidel\n"

if (test $# -lt 2 || test $# -gt 2)
then
        echo -e $USAGE
        exit 0
fi

make $1
rm -rf .tareador_precomputed_$1
tareador_gui.py --lite --llvm $1 -b "test.dat -n 4 -s 32 -a $2"
