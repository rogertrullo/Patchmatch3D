#include <string.h>
#include <cstdlib>

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


void improve_guess(float *a, float *b, int ar, int ac,int az, int &rbest, int &cbest,int &zbest, int &tbest, float &dbest,int br, int bc, int bz, int bt,int patch_w,int rows,int cols,int slices) {
  float d = patch_distance(a, b, ar,ac,az,br,bc, bz, bt,patch_w,rows,cols,slices);
  if (d < dbest) {
    dbest = d;
    rbest = br;
    cbest = bc;
    zbest = bz;
    tbest = bt;
  }
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //A,B,offsets,distances,wsearch,patch_w
       
    const mwSize *N = mxGetDimensions(prhs[1]);
    //mexPrintf("dimensions: %d ", dimensions);   
    
    float *A = (float *) mxGetData(prhs[0]);
    float *B = (float *) mxGetData(prhs[1]);
    //int *offsets = (int *) mxGetData(prhs[2]);
    //float *distances = (float *) mxGetData(prhs[3]);
    
    int wsearch= mxGetScalar(prhs[4]);
    int patch_w= mxGetScalar(prhs[5]);   
    
    mexPrintf("wsearc: %d ", wsearch);
    mexPrintf("\nwpatch: %d ", patch_w);

    
    int rows=N[0];
    int cols=N[1];
    int slices=N[2];
    int objects=N[3];
    int aew = cols- patch_w+1, aeh = rows - patch_w + 1,  aez= slices - patch_w +1;    /* Effective width and height (possible upper left corners of patches). */
    
    //const mwSize dim_offsets[4]= {N[0],N[1],N[2], 4};
   // plhs[0]= mxCreateNumericMatrix(0, 0,mxINT32_CLASS, mxREAL); /* Create an empty array */    
    //mxSetDimensions(plhs[0],(const mwSize *)dim_offsets, 4); /* Set the dimensions to N[0] x ... x N[K?1] */
    //mxSetData(plhs[0], mxMalloc(sizeof(int)*(N[0]*N[1]*N[2]*4))); /* Allocate memory */
    //int *offsets_o=(int *) mxGetData(plhs[0]);
    
    //plhs[1]= mxCreateNumericMatrix(0, 0,mxSINGLE_CLASS, mxREAL); /* Create an empty array */    
    //mxSetDimensions(plhs[1], (const mwSize *)N, 3); /* Set the dimensions to N[0] x ... x N[K?1] */
    //mxSetData(plhs[1], mxMalloc(sizeof(float)*(N[0]*N[1]*N[2]))); /* Allocate memory */
    //float *distances_o=(float *) mxGetData(plhs[1]);
    
    //MIRAR COMO COPIAR DATA
    
    plhs[0]=mxDuplicateArray(prhs[2]);
    int *offsets_o=(int *) mxGetData(plhs[0]);
    plhs[1]=mxDuplicateArray(prhs[3]);
    float *distances_o=(float *) mxGetData(plhs[1]);
    
    int pm_iters=4;
    
    mexPrintf("\naew=%d ",aew);
    mexPrintf("\naeh=%d",aeh);
    mexPrintf("\naez=%d",aez);
    
    for (int iter = 0; iter < pm_iters; iter++){
    
        mexPrintf("\nPar");
        int r_start = 0, r_end = aeh, r_change = 1;
        int c_start = 0, c_end = aew, c_change = 1;
        int z_start = 0, z_end = aez, z_change = 1;    

        if (iter % 2 == 1) {//impares
          r_start = r_end-1, r_end = -1, r_change = -1;
          c_start = c_end-1, c_end = -1, c_change = -1;
          z_start = z_end-1, z_end = -1, z_change = -1;
          mexPrintf("\nImpar");
        }    
    
        for (int az = z_start; az != z_end; az+=z_change){
            for (int ar = r_start; ar != r_end; ar+=r_change){
                for(int ac = c_start; ac != c_end; ac+=c_change){

                    int r_best=offsets_o[0*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar];
                    int c_best=offsets_o[1*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar];
                    int z_best=offsets_o[2*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar];
                    int t_best=offsets_o[3*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar];

                    float d_best = distances_o[az*(rows*cols)+ac*rows+ar];
                    //mexPrintf("\nfinished reading distances and offsets");
                     /* Propagation: Improve current guess by trying instead correspondences from left and above (below and right on odd iterations). */
                    //check left()
                    if ((unsigned) (ac - c_change) < (unsigned) aew){
                      int rp = offsets_o[0*(slices*rows*cols)+az*(rows*cols)+(ac-c_change)*rows+ar];//row of the element in the left() of the current position
                      int cp = offsets_o[1*(slices*rows*cols)+az*(rows*cols)+(ac-c_change)*rows+ar];//row of the element in the left() of the current position
                      cp=cp+c_change;//col right()
                      int zp = offsets_o[2*(slices*rows*cols)+az*(rows*cols)+(ac-c_change)*rows+ar];//row of the element in the left() of the current position
                      int tp = offsets_o[3*(slices*rows*cols)+az*(rows*cols)+(ac-c_change)*rows+ar];//idx in the left() of the current position


                      if ((unsigned) cp < (unsigned) aew){
                        improve_guess(A, B,ar,ac,az,r_best,c_best,z_best,t_best,d_best,rp,cp,zp,tp,patch_w,rows,cols,slices);
                      }
                    }
                    //mexPrintf("\nfinished checking left");
                    //check above ()
                    if ((unsigned) (ar - r_change) < (unsigned) aeh) {
                      int rp = offsets_o[0*(slices*rows*cols)+az*(rows*cols)+ac*rows+(ar-r_change)];//row of the element above() of the current position
                      rp=rp+r_change;// row down()
                      int cp=offsets_o[1*(slices*rows*cols)+az*(rows*cols)+ac*rows+(ar-r_change)];//col of the element above() of the current position
                      int zp=offsets_o[2*(slices*rows*cols)+az*(rows*cols)+ac*rows+(ar-r_change)];//slice of the element above() of the current position
                      int tp=offsets_o[3*(slices*rows*cols)+az*(rows*cols)+ac*rows+(ar-r_change)];//idx of elt above

                      if ((unsigned) rp < (unsigned) aeh) {
                        improve_guess(A, B,ar,ac,az,r_best,c_best,z_best,t_best,d_best,rp,cp,zp,tp,patch_w,rows,cols,slices);
                      }
                    }
                    //("\nfinished checking above");


                    //check slice above ()
                    if ((unsigned) (az - z_change) < (unsigned) aez) {
                      int rp = offsets_o[0*(slices*rows*cols)+(az-z_change)*(rows*cols)+ac*rows+ar];//row of the element in slice above() of the current position
                      int cp=offsets_o[1*(slices*rows*cols)+(az-z_change)*(rows*cols)+ac*rows+ar];//col of the element in slice above() of the current position
                      int zp=offsets_o[2*(slices*rows*cols)+(az-z_change)*(rows*cols)+ac*rows+ar];//slice of the element in slice above() of the current position
                      zp=zp+z_change;//slice down()
                      int tp=offsets_o[3*(slices*rows*cols)+(az-z_change)*(rows*cols)+ac*rows+ar];//idx of the element in slice above() of the current position

                      if ((unsigned) zp < (unsigned) aez) {
                        improve_guess(A, B,ar,ac,az,r_best,c_best,z_best,t_best,d_best,rp,cp,zp,tp,patch_w,rows,cols,slices);
                      }
                    }
                    //mexPrintf("\nfinished checking slice above");
                    //Random Search
                    //rand() % (HIGH - LOW + 1) + LOW;
                   // mexPrintf("antes del Random");
                    for (int mag = wsearch; mag >= 1; mag /= 2) {
                        
                        // Sampling window //
                        int cmin = MAX(c_best-mag, 0), cmax = MIN(c_best+mag+1,aew);
                        int rmin = MAX(r_best-mag, 0), rmax = MIN(r_best+mag+1,aeh);
                        int zmin = MAX(z_best-mag, 0), zmax = MIN(z_best+mag+1,aez);
                        //mexPrintf("\nfinished computing boundaries");
                        //mexPrintf("\nrmax:%d \nrmin:%d \ncmax:%d \ncmin:%d \nzmax:%d \nzmin:%d",rmax,rmin,cmax,cmin,zmax,zmin);
                        int rp = rmin+rand()%(rmax-rmin);
                        int cp = cmin+rand()%(cmax-cmin);
                        int zp = zmin+rand()%(zmax-zmin);
                        int tp = t_best;
                        //mexPrintf("\nfinished computing random values");
                        //mexPrintf("\nrp:%d \ncp:%d \nzp:%d \ntp:%d",rp,cp,zp,tp);
                        improve_guess(A, B,ar,ac,az,r_best,c_best,z_best,t_best,d_best,rp,cp,zp,tp,patch_w,rows,cols,slices);
                    }

                    //mexPrintf("\nfinish random search");
                    
                    //End Random Search
                    
                    offsets_o[0*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]=r_best;
                    offsets_o[1*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]=c_best;
                    offsets_o[2*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]=z_best;
                    offsets_o[3*(slices*rows*cols)+az*(rows*cols)+ac*rows+ar]=t_best;

                    distances_o[az*(rows*cols)+ac*rows+ar]=d_best;
                    
                    //mexPrintf("\nUpdate offsets and distances random search");
                    


                }



            }
     }
    
    
    
    
    
    
    
    }
    

    
   

    
    
}
