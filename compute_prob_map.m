function v=compute_prob_map(wmap,Blabels,array_off)
szw=size(wmap);

v=zeros(szw(1:3));
for i=1:szw(4)
    
    
    idxr=reshape(array_off(:,:,:,1,i),1,[]);
    idxc=reshape(array_off(:,:,:,2,i),1,[]);
    idxz=reshape(array_off(:,:,:,3,i),1,[]);
    idxt=reshape(array_off(:,:,:,4,i),1,[]);
    
    indices = sub2ind(size(Blabels), idxr, idxc, idxz, idxt);

    labels(:,:,:,i)=reshape(Blabels(indices),size(v));
end
v=sum(wmap.*labels,4)./(sum(wmap,4));

end