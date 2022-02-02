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
    double unnnew = *unew;
    int nt = omp_get_max_threads();
    int sync[nt];
    for(int a = 0; a < nt; ++a) sync[a] = -1;

		#pragma omp parallel private(diff, unnnew) reduction (+:sum) 
		{
			int threadid = omp_get_thread_num();
			int howmany = omp_get_num_threads();

			int nblocksi=howmany;
			int nblocksj=howmany;
			
			int i_start = lowerb(threadid,howmany,sizex);
			int i_end = upperb(threadid,howmany,sizex);
			
			for(int blockj = 0; blockj < nblocksj;++blockj){
				int j_start = lowerb(blockj,nblocksj,sizey);
				int j_end = upperb(blockj, nblocksj, sizey);
				int tmp = -1;
				while(threadid > 0 && sync[threadid] > tmp) {
					#pragma omp atomic read 
					tmp = sync[threadid-1];
				}
			
			for(int i = max(i_start,1); i <= min(sizex-2, i_end);++i) {
				for(int j = max(1, j_start); j <= min(sizey-2, j_end);++j) {
					unnnew = 0.25 * ( u[ i*sizey	   + (j-1) ] +  // left
								   u[ i*sizey	   + (j+1) ] +  // right
								   u[ (i-1)*sizey + j     ] +  // top
								   u[ (i+1)*sizey + j     ] ); // bottom
					diff = unnnew - u[i*sizey+ j];
					sum += diff * diff;
					u[i*sizey+j] = unnnew;
				}
			}
			#pragma omp atomic update
			sync[threadid]++;
		}
	}
	

		
	return sum;
}
