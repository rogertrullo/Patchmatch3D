%%
clear all
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Uncomment this part and comment the load commands below for loading 
%different elements that the ones saved in data and data_labels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rutesave='C:/Users/Roger Trullo/Documents/dataset/outlabel.nii.gz';
rute='/media/roger/48BCFC2BBCFC1562/dataset/prostate/3T_registered/';
rutelabels='/media/roger/48BCFC2BBCFC1562/dataset/prostate/labels_3T_registered/';
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


szdata=size(data);
dice1=zeros(1,szdata(4));
dice2=dice1;


%Parameters

wsearch=[5 7];
wpatch=[3 5 7];
Kg=[3:5];


%%

%low memory but runs sequentially and it should be reallyyyyyy slow :/
keyset={};
valset={};
for ws=1:size(wsearch,2)
    for wp=1:size(wpatch,2)
        for kidx=1:size(Kg,2)
            
             
             for idx=1:szdata(4)
                A=data(:,:,:,idx);
                szA=size(A);
                labelA=data_labels(:,:,:,idx);
                B=data;
                B(:,:,:,idx)=[];
                Blabels=data_labels;
                Blabels(:,:,:,idx)=[];
                array_off=int32(zeros([szA,4,Kg(kidx)]));
                array_dis=single(zeros([szA,Kg(kidx)]));    
                offsets1=int32(zeros([szA,4]));
                distances=single(zeros(szA));
                for id=1:Kg(kidx)    
                    [offsets1,distances1]=randinit(A,B,wsearch(ws),wpatch(wp));%A,b MUST be float(singles
                    disp('min')
                    min(min(min(offsets1)))
                    disp('max')
                    max(max(max(offsets1)))
                    [offsets,distances]=patchmatch3d(A,B,offsets1,distances1,wsearch(ws),wpatch(wp));
                    
                    array_off(:,:,:,:,id)=offsets+1;
                    array_dis(:,:,:,id)=distances;
                    clear offsets
                    clear distances
                    clear offsets1
                    clear distances1
                end
                %this uses lots of memory and a this points is not necessary...
                %clear A
                %clear B

                
                wmap=compute_weight_map(array_dis,array_off);
                v=compute_prob_map(wmap,Blabels,array_off);
                %imshow(v(:,:,14),[])
                disp('maps computed')

                %patch_labels=patchwise_labels(Blabels,array_off,wmap,wpatch);%slow matlab
                patch_labels=patches_cell(Blabels,array_off,wmap,wpatch(wp),Kg(kidx));%mex to the rescue :D
                disp('cell of patches created...')
                %labelmap=patch_fusion(patch_labels,wpatch);%slow matlab
                labelmap=fusion_patch(patch_labels,wpatch(wp));%better speed with mex :)
                disp('fusion of patches done...')
                labelavg=labelmap>0.5;
                %figure
                %imshow(labelavg(:,:,14),[])    
                labels=uint8(v>0.5);
                dice1(idx)=Compute_Dice(logical(labelA),labels);
                dice2(idx)=Compute_Dice(logical(labelA),labelavg);            

             end
             
             dices=[dice1;dice2];
             keyset=[keyset num2str([wsearch(ws),wpatch(wp),Kg(kidx)])]
             valset=[valset dices];          
            
        end
    end
end
 
mapObj = containers.Map(keyset,valset);

%%

for  i=1:length(valset)
    
    val=valset{i};
    avg=mean(val,2);
    key=keyset{i};
    fprintf('\n[ws  wp  k]=[%s]:  individual %.2f   avg: %.2f',key,avg(1),avg(2));   
    minis=min(val,[],2);
    maxis=max(val,[],2);
    
    fprintf('\n[ws  wp  k]=[%s]: min individual %.2f   avg: %.2f',key,minis(1),minis(2)); 
    fprintf('\n[ws  wp  k]=[%s]: max individual %.2f   avg: %.2f',key,maxis(1),maxis(2));   
end



