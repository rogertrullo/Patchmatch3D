function micell=patchwise_labels(Blabels,array_off,mapw,w)


szw=size(mapw);
rows=szw(1);
cols=szw(2);
slices=szw(3);
K=szw(4);
micell=cell(szw(1:3));

[micell{:}]=deal(single(zeros(w,w,w)));

% %not efficient way:
% parfor z=1:slices-w+1
%     for r=1:rows-w+1
%         for c=1:cols-w+1
%             for idx=1:K
%                 micell{r,c,z}=micell{r,c,z}+Blabels(array_off(r,c,z,1,idx):array_off(r,c,z,1,idx)+w-1,array_off(r,c,z,2,idx):array_off(r,c,z,2,idx)+w-1,...
%                     array_off(r,c,z,3,idx):array_off(r,c,z,3,idx)+w-1,array_off(r,c,z,4,idx))*mapw(r,c,z,idx);
%             end
%             micell{r,c,z}=micell{r,c,z}./(sum(mapw(r,c,z,:)));
% 
% 
%         end
%     end
% end
% delete(gcp('nocreate'))

norma=sum(mapw,4);
epsilon=0.001;

for z=1:slices-w+1
    for r=1:rows-w+1
        for c=1:cols-w+1
            for idx=1:K
                subpatch=patch3d(Blabels,array_off,r,c,z,idx,w);
                micell{r,c,z}=micell{r,c,z}+subpatch*mapw(r,c,z,idx);
            end
            
            micell{r,c,z}=micell{r,c,z}./(norma(r,c,z)+epsilon);


        end
    end
end

%delete(gcp('nocreate'))

end


function subpatch=patch3d(Blabels,array_off,r,c,z,idx,w)
subpatch=Blabels(array_off(r,c,z,1,idx):array_off(r,c,z,1,idx)+w-1,array_off(r,c,z,2,idx):array_off(r,c,z,2,idx)+w-1,...
                    array_off(r,c,z,3,idx):array_off(r,c,z,3,idx)+w-1,array_off(r,c,z,4,idx));


end


