#include "mex.h"
#include <string.h>

#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#define MIN(a, b) ((a)<(b)?(a):(b))
#endif

void fill_array(mxArray *cell_elt_ptr,float *Blabels,int *array_off,float *wmap,int patch_w,int ar, int ac, int az,int K, int rows,int cols,int slices,int objects)
{
    
    float *cell_element=(float *) mxGetData(cell_elt_ptr);
    for (int dz=0;dz<patch_w;dz++)
    {
        for (int dr = 0; dr < patch_w; dr++)
        {        
            for (int dc = 0; dc < patch_w; dc++)
            {    
                int index1=(dz)*(patch_w*patch_w)+(dc)*patch_w+(dr);
                float norm=0.0;
                for(int idx=0;idx<K;idx++)
                {  
                    
                    int lr=array_off[idx*(slices*rows*cols*4)+0*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]-1;//for matlab....
                    int lc=array_off[idx*(slices*rows*cols*4)+1*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]-1;
                    int lz=array_off[idx*(slices*rows*cols*4)+2*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]-1;
                    int lt=array_off[idx*(slices*rows*cols*4)+3*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]-1;

                    
                    
                    cell_element[index1]+=Blabels[lt*(slices*rows*cols)+(lz+dz)*(rows*cols)+(lc+dc)*rows+(lr+dr)]*wmap[idx*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar];
                    norm+=wmap[idx*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar];            
                
                }
                 
                 cell_element[index1]= cell_element[index1]/(norm+0.001);
                
          
            }    
        }    
    }

}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Blabels,array_off,mapw,patch_w,K
       
    const mwSize *N = mxGetDimensions(prhs[0]);
    
    //mexPrintf("dimensions: %d ", dimensions);   
    
    float *Blabels = (float *) mxGetData(prhs[0]);
    int *array_off = (int *) mxGetData(prhs[1]);
    float *wmap = (float *) mxGetData(prhs[2]);
    //int *offsets = (int *) mxGetData(prhs[2]);
    //float *distances = (float *) mxGetData(prhs[3]);
    
    int patch_w= (int)mxGetScalar(prhs[3]);
    int K=(int) mxGetScalar(prhs[4]);
       
    const mwSize szW[] ={patch_w,patch_w,patch_w};
    
        
    int rows=N[0];
    int cols=N[1];
    int slices=N[2];
    int objects=N[3];
    
    int index;
    mxArray  *cell_elt_ptr;
    mxArray *micell=mxCreateCellArray(3, N);
    plhs[0]=micell;

    
    int aew = cols- patch_w+1, aeh = rows - patch_w + 1,  aez= slices - patch_w +1;
    mexPrintf("\naew=%d ",aew);
    mexPrintf("\naeh=%d",aeh);
    mexPrintf("\naez=%d",aez);
    
    
    //initilia array with zeros
    mxArray *zeros_elt_ptr=mxCreateNumericMatrix(0, 0,mxSINGLE_CLASS, mxREAL); /* Create an empty array */    
    mxSetDimensions(zeros_elt_ptr, (const mwSize *)szW, 3); /* Set the dimensions to N[0] x ... x N[K?1] */
    mxSetData(zeros_elt_ptr,mxMalloc(sizeof(float)*(szW[0]*szW[1]*szW[2]))); /* Allocate memory */// DoI need to free? TODO
    float *ptr2array=(float *) mxGetData(zeros_elt_ptr);
    memset(ptr2array,0,sizeof(float)*(szW[0]*szW[1]*szW[2]));
    for (int az = 0; az < slices; az++)
    {
        for (int ar = 0; ar < rows; ar++)
        {
            for(int ac= 0; ac < cols; ac++)
            {               
                
                index=az*(rows*cols)+ac*rows+ar;
                if (ar<aeh && ac<aew && az<aez)
                {
                    //cell_elt_ptr=mxCreateNumericMatrix(0, 0,mxSINGLE_CLASS, mxREAL); /* Create an empty array */    
                    //mxSetDimensions(cell_elt_ptr, (const mwSize *)szW, 3); /* Set the dimensions to N[0] x ... x N[K?1] */
                    //mxSetData(cell_elt_ptr,mxMalloc(sizeof(float)*(szW[0]*szW[1]*szW[2]))); /* Allocate memory */// DoI need to free? TODO
                    cell_elt_ptr=mxDuplicateArray(zeros_elt_ptr);  
                    fill_array(cell_elt_ptr,Blabels,array_off,wmap,patch_w,ar,ac,az,K,rows,cols,slices,objects);
                    mxSetCell(micell, index, cell_elt_ptr);
                }
                else
                {
                    mxArray *zeros=mxDuplicateArray(zeros_elt_ptr);  
                    mxSetCell(micell, index, zeros);              
                
                }
                       
            
            }  
        }
     }

}