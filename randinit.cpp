#include <string.h>
#include "mex.h"

#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#define MIN(a, b) ((a)<(b)?(a):(b))
#endif

float patch_distance(float *a, float *b, int ar, int ac,int az, int br, int bc, int bz, int bt,int patch_w,int rows,int cols,int slices) {
  float ans = 0;
  float tmp;
  for (int dz=0;dz<patch_w;dz++)
  {
    for (int dr = 0; dr < patch_w; dr++)
    {
        
        for (int dc = 0; dc < patch_w; dc++)
        {            
          tmp=a[(az+dz)*(rows*cols)+(ac+dc)*rows+(ar+dr)]-b[bt*(slices*rows*cols)+(bz+dz)*(rows*cols)+(bc+dc)*rows+(br+dr)];
          ans+=(tmp*tmp);
          
          /*if(ar==0 && az==0 && ac==0)
                {
                    mexPrintf("\nall zeros  A[0]=%4.2f  ,B[offset[0]]=%4.2f, tmp=%4.2f",a[(az+dz)*(rows*cols)+(ac+dc)*rows+(ar+dr)],b[bt*(slices*rows*cols)+(bz+dz)*(rows*cols)+(bc+dc)*rows+(br+dr)],tmp*tmp);
                }
          */
          
         }    
     }
    
  }

  return ans;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //A,B,wsearch,patch_w
       
    const mwSize *N = mxGetDimensions(prhs[1]);
    //mexPrintf("dimensions: %d ", dimensions);   
    
    float *A = (float *) mxGetData(prhs[0]);
    float *B = (float *) mxGetData(prhs[1]);
    
    int wsearch= mxGetScalar(prhs[2]);
    int patch_w= mxGetScalar(prhs[3]);   
    
    mexPrintf("wsearc: %d ", wsearch);
    mexPrintf("\nwpatch: %d ", patch_w);

    
    int rows=N[0];
    int cols=N[1];
    int slices=N[2];
    int objects=N[3];
    int aew = cols- patch_w+1, aeh = rows - patch_w + 1,  aez= slices - patch_w +1;    /* Effective width and height (possible upper left corners of patches). */
    
    const mwSize dim_offsets[4]= {N[0],N[1],N[2], 4};
    plhs[0]= mxCreateNumericMatrix(0, 0,mxSINGLE_CLASS, mxREAL); /* Create an empty array */    
    mxSetDimensions(plhs[0],(const mwSize *)dim_offsets, 4); /* Set the dimensions to N[0] x ... x N[K?1] */
    mxSetData(plhs[0], mxMalloc(sizeof(float)*(N[0]*N[1]*N[2]*4))); /* Allocate memory */
    float *offsets=(float *) mxGetData(plhs[0]);
    
    plhs[1]= mxCreateNumericMatrix(0, 0,mxSINGLE_CLASS, mxREAL); /* Create an empty array */    
    mxSetDimensions(plhs[1], (const mwSize *)N, 3); /* Set the dimensions to N[0] x ... x N[K?1] */
    mxSetData(plhs[1], mxMalloc(sizeof(float)*(N[0]*N[1]*N[2]))); /* Allocate memory */
    float *distances=(float *) mxGetData(plhs[1]);
    mexPrintf("\naew=%d ",aew);
    mexPrintf("\naeh=%d",aeh);
    mexPrintf("\naez=%d",aez);
    
    int b_pos[4];//0-> row,1->col, 2->slice,3->index in library
    
   
    for (int az = 0; az < aez; az++)
    {
        for (int ar = 0; ar < aeh; ar++)
        {
            for(int ac= 0; ac < aew; ac++)
            {
                b_pos[0] = rand()%aeh;
                b_pos[1]= rand()%aew;
                b_pos[2]= rand()%aez;
                b_pos[3]= rand()%objects;
                
                for(int i=0;i<4;i++)
                {
                    
                    offsets[i*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]=b_pos[i];
                }
                
                distances[az*(rows*cols)+ac*rows+ar]=patch_distance(A,B,ar,ac,az,b_pos[0],b_pos[1], b_pos[2], b_pos[3],patch_w,rows,cols,slices);
                //mexPrintf("\nrow= %d, col= %d,z= %d",ar,ac,az);
                /*if(ar==0 && az==0 && ac==0)
                {
                    mexPrintf("\nall zeros1  A[0]=%d  ,b0=%d,b1=%d,b2=%d,b3=%d,",A[(az)*(rows*cols)+(ac)*rows+(ar)],b_pos[0],b_pos[1],b_pos[2],b_pos[3]);
                }*/
                
                
            
            }
            
            
            
        }
     }
    
    
}
