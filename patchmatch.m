function [offsets,distances]=patchmatch(A,B,wsearch,patch_w)

%patchmatch Implementation by Roger Trullo of the original paper of Barnes
%   A refers to the original image
%   B refers to the image where we will take the patches
%   halfwinsize is half of the patchsize, for ex for a 3x3 patch, it will
%   be 1

%Random Initialization
A=double(A);
B=double(B);
[offsets,distances] = randinit(A,B,wsearch,patch_w);
Apadded=padarray(A,[halfwinsize,halfwinsize]);

alpha=0.5;
w=max(size(B));
mag=w*alpha;
i=1;

while mag>1    
    Radious(i)=mag;
    i=i+1;
    mag=w*alpha^i;
end
    

 numIt = 10;
    for i = 1:numIt
       disp(['iteration ' int2str(i)])
       % Propagate matches down and right on odd steps, up and left on even
        if(mod(i,2)==0)
            [offsets,distances] = PropagateEven(Apadded,B,offsets,distances,halfwinsize,Radious);
       else
            [offsets,distances] = PropagateOdd(Apadded,B,offsets,distances,halfwinsize,Radious);
       end
        
        %RandomSearch(A,B,offsets,distances,halfwinsize); Wrong i think!
        %this should be after propagation in each patch
       
    end
    save offsets.mat

end

