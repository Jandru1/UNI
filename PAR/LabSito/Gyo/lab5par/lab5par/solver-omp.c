#include "heat.h"
#include "omp.h"
#define lowerb(id, p, n)  ( id * (n/p) + (id < (n%p) ? id : n%p) )
#define numElem(id, p, n) ( (n/p) + (id < (n%p)) )
#define upperb(id, p, n)  ( lowerb(id, p, n) + numElem(id, p, n) - 1 )

#define min(a, b) ( (a < b) ? a : b )
#define max(a, b) ( (a > b) ? a : b )

// Function to copy one matrix into another

void copy_mat (double *u, double *v, unsigned sizex, unsigned sizey) {

   #pragma omp parallel
    {
   int blocki=omp_get_thread_num();
int nblocksi=omp_get_num_threads();
      int i_start = lowerb(blocki, nblocksi, sizex);
      int i_end = upperb(blocki, nblocksi, sizex);
      for (int i=max(1, i_start); i<=min(sizex-2, i_end); i++) {
        for (int j=1; j<=sizey-2; j++)
            v[i*sizey+j] = u[i*sizey+j];
      }

}
}
/*
void copy_mat (double *u, double *v, unsigned sizex, unsigned sizey) {
    int nblocksi=8;
    for (int blocki=0; blocki<nblocksi; ++blocki) {
      int i_start = lowerb(blocki, nblocksi, sizex);
      int i_end = upperb(blocki, nblocksi, sizex);
      for (int i=max(1, i_start); i<=min(sizex-2, i_end); i++) {
        for (int j=1; j<=sizey-2; j++)
            v[i*sizey+j] = u[i*sizey+j];
      }
    }
}
*/
// 1D-blocked Jacobi solver: one iteration step
double relax_jacobi (double *u, double *utmp, unsigned sizex, unsigned sizey) {
    double diff, sum=0.0;

   int i,j;
#pragma omp parallel private(diff,i,j) reduction(+:sum)

{
	int blocki=omp_get_thread_num();
	int nblocksi=omp_get_num_threads();

      int i_start = lowerb(blocki, nblocksi, sizex);
      int i_end = upperb(blocki, nblocksi, sizex);
      for (i=max(1, i_start); i<=min(sizex-2, i_end); i++) {
        for (j=1; j<=sizey-2; j++) {
	      utmp[i*sizey+j] = 0.25 * ( u[ i*sizey     + (j-1) ] +  // left
	                                 u[ i*sizey     + (j+1) ] +  // right
                                     u[ (i-1)*sizey + j     ] +  // top
                                     u[ (i+1)*sizey + j     ] ) ;// bottom
	      diff = utmp[i*sizey+j] - u[i*sizey + j];
	      sum += diff * diff;
	    }
      }

}

    return sum;
}


double relax_gauss (double *u, unsigned sizex, unsigned sizey) {
    double unew, diff, sum=0.0;
    int nt = omp_max_num_threads();
    int sync[nt];

    #pragma omp parallel private(diff,unew) reduction(+:sum)
    {
        #pragma omp atomic update
        sync[id] = -1;
        int nblocksi=omp_get_num_threads();
        int nblocksj=nblocksi;
        int id = omp_get_thread_num();
        int i_start = lowerb(id, nblocksi, sizex);
        int i_end = upperb(id, nblocksi, sizex);
        for (int blockj=0; blockj<nblocksj; ++blockj) {
            int j_start = lowerb(blockj, nblocksj, sizey);
            int j_end = upperb(blockj, nblocksj, sizey);
            int tmp = -1;
                    while(id>0 && sync[id] > tmp){
                    #pragma omp atomic read
                    tmp = sync[id-1];
                }
                for (int i=max(1, i_start); i<=min(sizex-2, i_end); i++) {
                for (int j=max(1, j_start); j<=min(sizey-2, j_end); j++) {
                    unew = 0.25 * ( u[ i*sizey       + (j-1) ] +  // left
                                    u[ i*sizey       + (j+1) ] +  // right
                                    u[ (i-1)*sizey + j     ] +  // top
                                    u[ (i+1)*sizey + j     ] ); // bottom
                    diff = unew - u[i*sizey+ j];
                    sum += diff * diff;
                    u[i*sizey+j] = unew;
                }
            }
            #pragma omp atomic update
            sync[id]++;
        }
    }
    return sum;
}
