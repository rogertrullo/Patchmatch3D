%%

clear all
clc
close all

rutesave='C:/Users/Roger Trullo/Documents/dataset/outlabel.nii.gz';
rute='/media/roger/48BCFC2BBCFC1562/dataset/prostate/3T_registered/';
rutelabels='/media/roger/48BCFC2BBCFC1562/dataset/prostate/labels_3T_registered/';
num_lib=9;
pad=20;
prefix='Warped';
prefixlabels='labelwarped';
wsearch=3;
wpatch=4;

K=3;
%%

[A,B] = loadvolumes(num_lib,prefix,0,'nii.gz',rute);

[labelA,Blabels] = loadvolumes(num_lib,prefixlabels,0,'nii.gz',rutelabels);

%this is because we have labels 1 and 2 so we turn 2 into 1 as main label
Blabels(Blabels==1)=0;
Blabels(Blabels==2)=1;

labelA(labelA==1)=0;
labelA(labelA==2)=1;


sza=size(A);
%array_off=zeros([sza,4,K]);
%array_dis=zeros([sza,K]);

%[offsetst,distancest]=randinit(A,B,wsearch,wpatch);



%%

for i=1:K
    
    [offsetst,distancest]=randinit(A,B,wsearch,wpatch);%A,b MUST be float(singles)
    disp('min')
    min(min(min(offsetst)))
    disp('max')
    max(max(max(offsetst)))
    [offsets,distances]=patchmatch3d(A,B,offsetst,distancest,wsearch,wpatch);
    array_off(:,:,:,:,i)=offsets+1;
    array_dis(:,:,:,i)=distances;
end

%this uses lots of memory and a this points is not necessary...
clear A
clear B

%%


wmap=compute_weight_map(array_dis,array_off);

v=compute_prob_map(wmap,Blabels,array_off);
imshow(v(:,:,14),[])

disp('maps computed')

%%

%patch_labels=patchwise_labels(Blabels,array_off,wmap,wpatch);%slow matlab
patch_labels=patches_cell(Blabels,array_off,wmap,wpatch,K);%mex to the rescue :D


%labelmap=patch_fusion(patch_labels,wpatch);%slow matlab
labelmap=fusion_patch(patch_labels,wpatch);%better speed with mex :)


labelavg=labelmap>0.5;
figure
imshow(labelavg(:,:,14),[])
%%
labels=uint8(v>0.5);
dice1=Compute_Dice(logical(labelA),labels)
dice2=Compute_Dice(logical(labelA),labelavg)


% ni=make_nii(labels);
% save_nii(ni,rutesave)

