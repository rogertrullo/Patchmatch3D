#include <string.h>
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mwSize total_num_of_cells;
    const mxArray *cell_element_ptr;
    const mwSize *N = mxGetDimensions(prhs[0]);
    int rows=N[0];
    int cols=N[1];
    int slices=N[2];
    const mwSize P = mxGetNumberOfDimensions(prhs[0]);
    total_num_of_cells = mxGetNumberOfElements(prhs[0]); 

    mexPrintf("total num of cells = %d\n", total_num_of_cells);
    mexPrintf("\n");
    mexPrintf("\n N[0]=%d ",N[0]);
    mexPrintf("\n N[1]=%d ",N[1]);
    mexPrintf("\n N[2]=%d ",N[2]);
    mexPrintf("\n P[0]=%d ",P);

    //cell_element_ptr = mxGetCell(prhs[0], index);
    int nsubs=3;
    mwIndex  subs[]={0,2,0};
    int index = mxCalcSingleSubscript(prhs[0], nsubs, subs);
    
    int idx=subs[2]*(rows*cols)+subs[1]*rows+subs[0];
    //const mwSize *L = mxGetDimensions(prhs[0][idx]);
    mexPrintf("\n index=%d ",index);
    mexPrintf("\n idx=%d ",idx);
    cell_element_ptr = mxGetCell(prhs[0], index);
    N = mxGetDimensions(cell_element_ptr);
    mexPrintf("\n size of the cell element ");
    mexPrintf("\n N[0]=%d ",N[0]);
    mexPrintf("\n N[1]=%d ",N[1]);
    mexPrintf("\n N[2]=%d ",N[2]);
  
}