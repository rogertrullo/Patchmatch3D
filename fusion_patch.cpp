#include <string.h>
#include "mex.h"

#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#define MIN(a, b) ((a)<(b)?(a):(b))
#endif



float compute_sum(const mwSize *M,const mxArray *cell_elt_ptr)
{
    float *A = (float *) mxGetData(cell_elt_ptr);
    float sum=0.0;
    int rows=M[0];
    int cols=M[1];
    int slices=M[2];
    for (int az = 0; az < slices; az++)
    {
        for (int ar = 0; ar < rows; ar++)
        {
            for(int ac= 0; ac < cols; ac++)
            {
               sum+=A[az*(rows*cols)+ac*rows+ar];
                       
            
            }  
        }
     }
    
    return sum;
    
}


float compute_mean(int r, int c, int z,const mxArray *cell_ptr, int w)
{
    int rstart=MAX(0,r-w+1);
    int cstart=MAX(0,c-w+1);
    int zstart=MAX(0,z-w+1);
    const mxArray *cell_element_ptr;
    int index;//hold index for the specific element in the cell
    const mwSize *N = mxGetDimensions(cell_ptr);//cell dimension
    //const mwSize *M;//cell element dimension
    /////for the complete cell////
    int rows=N[0];
    int cols=N[1];
    int slices=N[2];
    //////////////////////////////
    /////for the cell element/////
    int rows_c;
    int cols_c;
    int slices_c;
    ////////////////////////////
    float tmp=0.0;
    float cnt=0.0;
    //mexPrintf("rows: %d ", rows);
    mwSize total_entries;
    for (int dz=zstart;dz<=z;dz++)
    {
        for (int dr=rstart;dr<=r;dr++)
        {            
            for(int dc=cstart;dc<=c;dc++)
            {           
                index=dz*(rows*cols)+dc*rows+dr;
                cell_element_ptr = mxGetCell(cell_ptr, index);
                total_entries=mxGetNumberOfElements(cell_element_ptr);//it shuld be W^3
                const mwSize *M=mxGetDimensions(cell_element_ptr);// dimensions of specific cell element (it should be W*W*W)
                //mexPrintf("\nrows sub: %d ", M[0]);
                tmp+=compute_sum(M,cell_element_ptr);
                cnt+=total_entries;
                               
            }          
        }     
    }
    //if (r==0 && c==0 && z==0){
    //mexPrintf("\navg: %3.2f ", cnt);
    //}
    
    return (tmp/cnt);
    
}
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //cell,wpatch
    int wpatch= mxGetScalar(prhs[1]);
    const mwSize *N = mxGetDimensions(prhs[0]);
    int rows=N[0];
    int cols=N[1];
    int slices=N[2];
    plhs[0]= mxCreateNumericMatrix(0, 0,mxSINGLE_CLASS, mxREAL); /* Create an empty array */    
    mxSetDimensions(plhs[0], (const mwSize *)N, 3); /* Set the dimensions to N[0] x ... x N[K?1] */
    mxSetData(plhs[0], mxMalloc(sizeof(float)*(N[0]*N[1]*N[2]))); /* Allocate memory */
    float *labels=(float *) mxGetData(plhs[0]);
    
    
    for (int az = 0; az < slices; az++)
    {
        for (int ar = 0; ar < rows; ar++)
        {
            for(int ac= 0; ac < cols; ac++)
            {
               labels[az*(rows*cols)+ac*rows+ar]=compute_mean(ar, ac, az,prhs[0], wpatch);
                       
            
            }  
        }
     }

    
  
}