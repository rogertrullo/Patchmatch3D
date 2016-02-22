%%

clear all
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Uncomment this part and comment the load commands below for loading 
%different elements that the ones saved in data and data_labels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rutesave='C:/Users/Roger Trullo/Documents/dataset/outlabel.nii.gz';
% rute='C:/Users/Roger Trullo/Documents/dataset/prostate/3T_registered/';
% rutelabels='C:/Users/Roger Trullo/Documents/dataset/prostate/labels_3T_registered/';
% num_lib=17;%its actually 16 cause one elt is not in the library, also a multiple of num of cores so parfor is more efficient 
% prefix='Warped';
% prefixlabels='labelwarped';
% data = loadvolumes_complete(num_lib,prefix,'nii.gz',rute);
% 
% data_labels = loadvolumes_complete(num_lib,prefixlabels,'nii.gz',rutelabels);
% 
% %this is because we have labels 1 and 2 so we turn 2 into 1 as main label
% data_labels(data_labels==1)=0;
% data_labels(data_labels==2)=1;


load data.mat
load data_labels.mat

%%
%Parameters

wsearch=3;
wpatch=4;
K=7;



%%

%This part is just for making the parallel faster but it needs more memory :S
szdata=size(data);
data1=single(zeros([szdata(1:3),szdata(4)-1,szdata(4)]));
labels1=data1;
for i=1:szdata(4)
    tmp=data;
    tmp(:,:,:,i)=[];
    data1(:,:,:,:,i)=tmp;
    tmp=data_labels;
    tmp(:,:,:,i)=[];
    labels1(:,:,:,:,i)=tmp;
    
    
end
clear tmp
dice1=zeros(1,szdata(4));
dice2=dice1;

parfor idx=1:szdata(4)
    A=data(:,:,:,idx);
    szA=size(A);
    labelA=data_labels(:,:,:,idx);
    B=data1(:,:,:,:,idx);
    Blabels=labels1(:,:,:,:,idx);
    array_off=int32(zeros([szA,4,K]));
    array_dis=single(zeros([szA,K]));    
    
    for i=1:K    
        [offsets,distances]=randinit(A,B,wsearch,wpatch);%A,b MUST be float(singles)
        [offsets,distances]=patchmatch3d(A,B,offsets,distances,wsearch,wpatch);
        array_off(:,:,:,:,i)=offsets+1;
        array_dis(:,:,:,i)=distances;
    end
%this uses lots of memory and a this points is not necessary...
    %clear A
    %clear B
    
    wmap=compute_weight_map(array_dis,array_off);
    v=compute_prob_map(wmap,Blabels,array_off);
    %imshow(v(:,:,14),[])
    disp('maps computed')
    
    %patch_labels=patchwise_labels(Blabels,array_off,wmap,wpatch);%slow matlab
    patch_labels=patches_cell(Blabels,array_off,wmap,wpatch,K);%mex to the rescue :D
    disp('cell of patches created...')
    %labelmap=patch_fusion(patch_labels,wpatch);%slow matlab
    labelmap=fusion_patch(patch_labels,wpatch);%better speed with mex :)
    disp('fusion of patches done...')
    labelavg=labelmap>0.5;
    %figure
    %imshow(labelavg(:,:,14),[])    
    labels=uint8(v>0.5);
    dice1(idx)=Compute_Dice(logical(labelA),labels)
    dice2(idx)=Compute_Dice(logical(labelA),labelavg) 
    
    
    
end
delete(gcp('nocreate'))


