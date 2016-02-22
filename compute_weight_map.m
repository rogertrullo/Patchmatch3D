function W=compute_weight_map(array_distances,array_off)
epsilon=0.0001;
sigma=2;%in the paper says normalization but it is not clear to me with respect to what...
alpha=50;
K=size(array_distances,4);
sza=size(array_distances);
h=min(array_distances,[],4)+epsilon;%min over the K maps
h=repmat(h,1,1,1,K); %the same h for all the K maps
[cols,rows,slices]=meshgrid(1:sza(1),1:1:sza(2),1:1:sza(3));

indexes=cat(4,rows,cols,slices);
indexes=repmat(indexes,[1,1,1,1,K]);
clear rows cols slices;

spacial_dis=indexes-double(array_off(:,:,:,1:3,:));% we dont care about the t index
spacial_dis=spacial_dis.^2;
spacial_dis=sum(spacial_dis,4);
spacial_dis=squeeze(spacial_dis);% remove singleton (dimensions =1)

W=exp(-1*(array_distances./(alpha*h)+sqrt(spacial_dis)./sigma));%WRONG!!!! distances is not in array distances that the SSD!!!! TODO--SOLVED!

end