%%
clear all
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Uncomment this part and comment the load commands below for loading 
%different elements that the ones saved in data and data_labels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rutesave='C:/Users/Roger Trullo/Documents/dataset/outlabel.nii.gz';
rute='C:/Users/Roger Trullo/Documents/dataset/prostate/3T_registered/';
rutelabels='C:/Users/Roger Trullo/Documents/dataset/prostate/labels_3T_registered/';
num_lib=9;%its actually 16 cause one elt is not in the library, also a multiple of num of cores so parfor is more efficient 
prefix='Warped';
prefixlabels='labelwarped';
data = loadvolumes_complete(num_lib,prefix,'nii.gz',rute);

data_labels = loadvolumes_complete(num_lib,prefixlabels,'nii.gz',rutelabels);

%this is because we have labels 1 and 2 so we turn 2 into 1 as main label
data_labels(data_labels==1)=0;
data_labels(data_labels==2)=1;


% load data.mat
% load data_labels.mat

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


%Parameters

wsearch=repmat([5 7],szdata(4),1);
wpatch=repmat([3 5 7],szdata(4),1);
K=repmat(2:5,szdata(4),1);


%%
keyset={};
valset={};
for ws=1:size(wsearch,2)
    for wp=1:size(wpatch,2)
        for k=1:size(K,2)
            
             wstmp=wsearch(:,ws); 
             wptmp=wpatch(:,wp);
             ktmp=K(:,k);

             parfor idx=1:szdata(4)
                A=data(:,:,:,idx);
                szA=size(A);
                labelA=data_labels(:,:,:,idx);
                B=data1(:,:,:,:,idx);
                Blabels=labels1(:,:,:,:,idx);
                array_off=int32(zeros([szA,4,ktmp(idx)]));
                array_dis=single(zeros([szA,ktmp(idx)]));    

                for i=1:ktmp(idx)    
                    [offsets,distances]=randinit(A,B,wstmp(idx),wptmp(idx));%A,b MUST be float(singles)
                    [offsets,distances]=patchmatch3d(A,B,offsets,distances,wstmp(idx),wptmp(idx));
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
                patch_labels=patches_cell(Blabels,array_off,wmap,wptmp(idx),ktmp(idx));%mex to the rescue :D
                disp('cell of patches created...')
                %labelmap=patch_fusion(patch_labels,wpatch);%slow matlab
                labelmap=fusion_patch(patch_labels,wptmp(idx));%better speed with mex :)
                disp('fusion of patches done...')
                labelavg=labelmap>0.5;
                %figure
                %imshow(labelavg(:,:,14),[])    
                labels=uint8(v>0.5);
                dice1(idx)=Compute_Dice(logical(labelA),labels);
                dice2(idx)=Compute_Dice(logical(labelA),labelavg);            

             end
             clear patch_labels A B
             delete(gcp('nocreate'))
             dices=[dice1;dice2];
             keyset=[keyset num2str([wsearch(1,ws),wpatch(1,wp),K(1,k)])]
             valset=[valset dices];          
            
        end
    end
end
 
mapObj = containers.Map(keyset,valset);




