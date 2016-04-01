function [B] = loadvolumes_complete(k,prefix,ext,path1)
    %need the toolbox of Dirk for readinig mha files and niftit toolbox for
    %nii files
    %A image original
    %B library of images
    %k idxmax of image to put in the library, eg. if 19
    %prefix is the prefix for example test00.mha to test19.mha, prefix is
    %test.
    %idx with 2 digits for the image A, the rest
    %is the library
    %ext is the extension, eg 'nii.gx'
    %pad is the number of zeors to quit
    
    
    name=strcat(path1,prefix);
    idxtmp=[];
  
    for i=1:k

        tmp=sprintf(strcat(name,'%02d','.',ext),i-1);
        if ~exist(tmp, 'file')
      % File exists.  Do stuff....
            fprintf('\nfile does not exist:\n%s', tmp);
            idxtmp=[idxtmp,i];
            continue
        else
            if  strcmp(ext,'mha')
                B_t=ReadData3D(tmp,false);
            elseif strcmp(ext,'nii.gz')
                tmpB=load_nii(tmp);
                B_t=tmpB.img;
            elseif strcmp(ext,'nrrd')
                [B_t,~]=nrrdread(tmp);
                
            
            end  
            B(:,:,:,i)=B_t;
            
            fprintf('\nfile :\n%s  loaded', tmp);
%             figure
%             imshow(B(:,:,15,i),[])
%             pause
        end
         
    end
     
    %delete(gcp('nocreate'))
    B(:,:,:,idxtmp)=[];%Delete element that is actually A and elts that dont exist. this doesnt make sense but it is the only way I found to run it in parallel :/
    
   
end