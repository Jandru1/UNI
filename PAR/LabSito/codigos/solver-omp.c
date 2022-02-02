#define lowerb(id, p, n)  ( id * (n/p) + (id < (n%p) ? id : n%p) )
#define numElem(id, p, n) ( (n/p) + (id < (n%p)) )
#define upperb(id, p, n)  ( lowerb(id, p, n) + numElem(id, p, n) - 1 )

#define min(a, b) ( (a < b) ? a : b )
#define max(a, b) ( (a > b) ? a : b )

extern int userparam;

// Function to copy one matrix into another
void copy_mat (double *u, double *v, unsigned sizex, unsigned sizey) {
    int nblocksi=8;
    int nblocksj=1;
    for (int blocki=0; blocki<nblocksi; ++blocki) {
      int i_start = lowerb(blocki, nblocksi, sizex);
      int i_end = upperb(blocki, nblocksi, sizex);
      for (int blockj=0; blockj<nblocksj; ++blockj) {
        int j_start = lowerb(blockj, nblocksj, sizey);
        int j_end = upperb(blockj, nblocksj, sizey);
        for (int i=max(1, i_start); i<=min(sizex-2, i_end); i++)
          for (int j=max(1, j_start); j<=min(sizey-2, j_end); j++)
            v[i*sizey+j] = u[i*sizey+j];
      }
    }
}

//gauss
double solve (double *u, unsigned sizex, unsigned sizey) {
    double unew, diff, sum=0.0;
    int nt = omp_get_max_threads();
    int sync[nt];
    for(int a = 0; a < nt; ++a) sync[nt] = -1;
        
    #pragma omp parallel private(diff,unew) reduction(+:sum)
    {
    int nblocksi = omp_get_num_threads();
    int nblocksj = nblocksi; //no userparam
    // int nblocksj = userparam;
    int blocki = omp_get_thread_num();
    int i_start = lowerb(blocki, nblocksi, sizex);
    int i_end = upperb(blocki, nblocksi, sizex);
    for (int blocki=0; blocki<nblocksi; ++blocki) {
      for (int blockj=0; blockj<nblocksj; ++blockj) {
        int j_start = lowerb(blockj, nblocksj, sizey);
        int j_end = upperb(blockj, nblocksj, sizey);
        int tmp = -1;
        while(blocki > 0 && sync[blocki] > tmp){
            #pragma omp atomic read
            tmp = sync[blocki - 1];
        }
        for (int i=max(1, i_start); i<=min(sizex-2, i_end); i++) {
          for (int j=max(1, j_start); j<=min(sizey-2, j_end); j++) {
	        unew = 0.25 * ( u[ i*sizey	   + (j-1) ] +  // left
                           u[ i*sizey	   + (j+1) ] +  // right
                           u[ (i-1)*sizey + j     ] +  // top
                           u[ (i+1)*sizey + j     ] ); // bottom
	        diff = unew - u[i*sizey+ j];
	        sum += diff * diff;
	        u[i*sizey+j] = unew;
          }
        }
        #pragma omp atomic update
        ++sync[blocki];
      }
    }
    }
    return sum;
}
