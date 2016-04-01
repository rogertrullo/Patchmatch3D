function labelmap=patch_fusion(cell_labels,w)

sza=size(cell_labels);
rows=sza(1);
cols=sza(2);
slices=sza(3);
labelmap=single(zeros(sza));
parfor z=1:slices
    for r=1:rows
        for c=1:cols
            
            tmp=sub_cell(cell_labels,r,c,z,w)
            sub=cell2mat(tmp);
            avg=mean(sub(:));
            labelmap(r,c,z)=avg;
            %disp([r c z])
            
        end
    end
end
delete(gcp('nocreate'))
end

function tmp=sub_cell(cell_labels,r,c,z,w)

tmp=cell_labels(max(1,r-w+1):r,max(1,c-w+1):c,max(1,z-w+1):z);
end