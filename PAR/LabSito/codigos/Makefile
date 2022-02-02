CC     =  icc
TAREADORCC = tar-clang
TAREADOR_FLAGS = -tareador-lite


OPTG0 	= -g -O0
OPT3 	= -O3
CFLAGS  = -Wall -std=c99
LFLAGS  = -lm

CINCL    = -I.
CLIBS    = -L. -lm

TARGETS	= heat heat-tareador heat-omp
all: $(TARGETS)

heat: heat.c solver.c misc.c
	$(CC) $(CFLAGS) $(OPT3) $+ $(LFLAGS) -o $@

heat-tareador: heat-tareador.c solver-tareador.c misc.c
	$(TAREADORCC) $(TAREADOR_FLAGS) $(CFLAGS) $(OPTG0) $+ $(CINCL) -o $@ $(LFLAGS) $(CLIBS)

heat-omp: heat.c solver-omp.c misc.o
	$(CC) $(CFLAGS) $(OPT3) -fopenmp $+ $(LFLAGS) -o $@

clean:
	rm -fr $(TARGETS) *.o .tareador_precomputed* *.log

ultraclean:
	rm -fr $(TARGETS) logs *.sh.o* *.sh.e* *.o *.ppm .tareador_precomputed* *.prv *.pcf *.row dependency_graph* *.times.txt *.ps *.txt *.log TRACE.* set-0 logs
