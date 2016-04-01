function [offsets,distances] = InitRand(A,B,w,w1)
%UNTITLED8 Summary of this function goes here
%   A original 3d image
%   B library of 3d images (4D)-4th dimension is the idx in the library
%   The images are supossed to be the same size (after linear registration)
%   w is the window for initial random assignment
%   w1 is half patch size-1 eg for 3x3 td be 1, for 9 itd be 4

asz=size(A);%size of original image
bsz=size(B);%size of image were we will take patches from

if ~isequal(asz,bsz(1:3))
    error('The size of the query image differs from the library')    
end
m=asz(1);%rows
n=asz(2);%cols
l=asz(3);%slices
offsets=zeros(m,n,l,4);%size of the image and 4th idx for the library
distances=inf(asz);
fprintf('0%%----------100%%\n >'); % ten %s.
dispProgress = false((l-2*w1)*(m-2*w1)*(n-2*w1),1);
dispInterval = floor((l-2*w1)*(m-2*w1)*(n-2*w1)/10);
dispProgress(dispInterval:dispInterval:end) = true;
tic
myCluster=parcluster('local'); 
myCluster.NumWorkers=8
parpool(myCluster,8)
bsz1=bsz(4);
parfor k=1+w1:l-w1
    for i=1+w1:m-w1
        for j=1+w1:n-w1
            irnd=randi([max(i-w,1+w1) min(i+w,m-w1)]);
            jrnd=randi([max(j-w,1+w1) min(j+w,n-w1)]);
            krnd=randi([max(k-w,1+w1) min(k+w,l-w1)]);
            trnd=randi(bsz1);
            
            offsets(i,j,k,:)=[irnd jrnd krnd trnd];
            %distances(i,j,k)=sumsqr(reshape(A(i-w1:i+w1,j-w1:j+w1,k-w1:k+w1),[],1)-...
            %reshape(B(offsets(i,j,k,1)-w1:offsets(i,j,k,1)+w1,offsets(i,j,k,2)-w1:offsets(i,j,k,2)+w1,...
            %offsets(i,j,k,3)-w1:offsets(i,j,k,3)+w1,offsets(i,j,k,4)),[],1));
            
            
            distances(i,j,k)=sumsqr(reshape(A(i-w1:i+w1,j-w1:j+w1,k-w1:k+w1),[],1)-...
            reshape(B(irnd-w1:irnd+w1,jrnd-w1:jrnd+w1,...
            krnd-w1:krnd+w1,trnd),[],1));
            
            %if dispProgress((k-1-w1)*(m-2*w1)*(n-2*w1)+(i-1-w1)*(m-2*w)+j); fprintf('='); end
            
        end
        
    end
    %disp(k)
end

toc
end

