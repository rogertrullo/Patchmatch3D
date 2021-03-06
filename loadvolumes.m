function [A,B] = loadvolumes(k,prefix,idx,ext,path1)
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
    tmp=sprintf(strcat(name,'%02d','.',ext),idx);
    
    if ~exist(tmp, 'file')
      % File doesnt exist ....
      error('\nfile does not exist:\n%s', tmp);
    end
    if strcmp(ext,'mha')
        A=ReadData3D(tmp,false);
        
    elseif strcmp(ext,'nii.gz')
        tmpA=load_nii(tmp);
        A=tmpA.img;
    else
        error('extension %s not supported',ext)
    end
    %A=A(pad+1:size(A,1)-pad,pad+1:size(A,2)-pad,pad+1:size(A,3)-pad);
    idxtmp=idx+1;
    for i=1:k
      %t = getCurrentTask();
      %disp(t.ID);
        if i==idx+1
            continue
        end
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