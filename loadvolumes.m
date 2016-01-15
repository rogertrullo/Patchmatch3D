function [A,B] = loadvolumes(k,prefix,path1)
    %need the toolbox of Dirk for readinig mha files
    %A image original
    %B library of images
    %k number of images to put in the library
    %prefix is the prefix for example test00.mha to test19.mha, prefix is
    %test. We assume idx from 0, and 2 digits. idx is the image A, the rest
    %is the library
    
    idx=0;
    name=strcat(path1,prefix);
    tmp=sprintf(strcat(name,'%02d','.mha'),idx);
    
    if ~exist(tmp, 'file')
      % File doesnt exist ....
      error('file does not exist:\n%s', tmp);
    end
    A=ReadData3D(tmp,false);
    for i=1:k
        tmp=sprintf(strcat(name,'%02d','.mha'),i);
        if ~exist(tmp, 'file')
      % File exists.  Do stuff....
            error('file does not exist:\n%s', tmp);
        else
            
            B(:,:,:,i)=ReadData3D(tmp,false);
            fprintf('file :\n%s  loaded', tmp);
            figure
            imshow(B(:,:,100,i),[])
        end
         
     end
        
    
   
end