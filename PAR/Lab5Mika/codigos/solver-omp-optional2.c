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
    #pragma omp parallel 
    {
		int threadid = omp_get_thread_num();
		int howmany = omp_get_num_threads();
		
		int i_start = lowerb(threadid,howmany,sizex);
		int i_end = upperb(threadid,howmany,sizex);
		
		for(int i = max(i_start,1); i <= min(sizex-2, i_end);++i) {
			for(int j = 1; j <= sizey-2;++j) {
				v[i*sizey+j] = u[i*sizey+j];
			}
		}
	}
}

// 2D-blocked solver: one iteration step
double solve (double *u, double *unew, unsigned sizex, unsigned sizey) {
    double tmp, diff, sum=0.0;
    int threads = omp_get_max_threads();
	char m[threads][threads];
	#pragma omp parallel shared(sum)
	#pragma omp single
	{
    for (int blockid = 0; blockid < omp_get_num_threads(); ++blockid) {
		for(int blockid_col = 0; blockid_col < omp_get_num_threads(); ++blockid_col) {
			int howmany = omp_get_num_threads();
		    int i_start = lowerb(blockid, howmany, sizex);
		    int i_end = upperb(blockid, howmany, sizex);
		    int j_start = lowerb(blockid_col, howmany, sizey);
		    int j_end = upperb(blockid_col, howmany, sizey);
      
      
		  #pragma omp task depend(in: m[blockid-1][blockid_col], m[blockid, blockid_col-1]) depend(out: m[blockid, blockid_col])
		  {
		  double sum_local;
		   
		  for (int i=max(1, i_start); i<= min(sizex-2, i_end); i++) {
			for (int j= max(1, j_start); j<= min(j_end, sizey-2); j++) {
			*unew= 0.25 * ( u[ i*sizey	+ (j-1) ]+  // left
				   u[ i*sizey	+ (j+1) ]+  // right
				   u[ (i-1)*sizey	+ j     ]+  // top
				   u[ (i+1)*sizey	+ j     ]); // bottom
			diff = *unew - u[i*sizey+ j];
			sum += diff * diff; 
			u[i*sizey+j]=*unew;
			}
		  }
		  #pragma omp atomic
		  sum += sum_local;
				}
			}
		}
	}
    return sum;
}
