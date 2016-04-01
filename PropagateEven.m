
function [offsets,distances] = PropagateEven(Apadded,B,offsets,distances,w,radvec)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

asz=size(offsets);
bsz=size(B);

fprintf('0%%----------100%%\n >'); % ten %s.
dispProgress = false(asz(1)*asz(2),1);
dispInterval = floor(asz(1)*asz(2)/10);
dispProgress(dispInterval:dispInterval:end) = true;
for i=asz(1):-1:1
    for j=asz(2):-1:1
        
        disvec=inf(1,3);% vector de dstancias center left up
        disvec(1)=distances(i,j);
        %positions in image B
%         icentral=offsets(i,j,1)+i;
%         jcentral=offsets(i,j,2)+j;
        
%        ileft=offsets(i,j-1,1)+i;
        jright=offsets(i,min(j+1,asz(2)),2)+min(j+1,asz(2));
        
        idown=offsets(min(i+1,asz(1)),j,1)+min(i+1,asz(1));
%        jup=offsets(i-1,j,2)+j;
        
        %check to the left
        if jright-1>1+w%if the position one pixel to the left in B is inside B
            disvec(2)=distances(i,min(j+1,asz(2)));           
        end
        
        %check down
        if idown-1>1+w
            disvec(3)=distances(min(i+1,asz(1)),j);
        end
                
        [~,idxmin]=min(disvec);
        
        switch idxmin
            case 2%right is better
                offsets(i,j,:)=offsets(i,min(j+1,asz(2)),:);
                ii=offsets(i,j,1)+i;
                jj=offsets(i,j,2)+j;
                %distances(i,j)=sumsqr(reshape(Apadded(i-w+w:i+w+w,j-w+w:j+w+w,:),[],1)-...
                %reshape(B(ii-w:ii+w,jj-w:jj+w,:),[],1));
                distances(i,j)=distancemex(reshape(Apadded(i-w+w:i+w+w,j-w+w:j+w+w,:),[],1),...
                reshape(B(ii-w:ii+w,jj-w:jj+w,:),[],1));
                
                
            case 3%down is better
                offsets(i,j,:)=offsets(min(i+1,asz(1)),j,:);
                ii=offsets(i,j,1)+i;
                jj=offsets(i,j,2)+j;
                %distances(i,j)=sumsqr(reshape(Apadded(i-w+w:i+w+w,j-w+w:j+w+w,:),[],1)-...
                %reshape(B(ii-w:ii+w,jj-w:jj+w,:),[],1));
                distances(i,j)=distancemex(reshape(Apadded(i-w+w:i+w+w,j-w+w:j+w+w,:),[],1),...
                reshape(B(ii-w:ii+w,jj-w:jj+w,:),[],1));
                
                
        end
        
        %%%%%%%%%%%%%%%%%%%%%%
        %--  RandomSearch  --%
        %%%%%%%%%%%%%%%%%%%%%%
        lenRad=length(radvec);
        i_min = max(1+w,offsets(i,j,1)+i-radvec(:));
        i_max = min(offsets(i,j,1)+i+radvec(:),bsz(1)-w);
        j_min = max(1+w,offsets(i,j,2)+j-radvec(:));
        j_max = min(offsets(i,j,2)+j+radvec(:),bsz(2)-w);
        
        i_rdn=round(rand(lenRad,1).*(i_max(:)-i_min(:))+ i_min(:));
        j_rdn=round(rand(lenRad,1).*(j_max(:)-j_min(:))+ j_min(:));
        
        bestdist=distances(i,j);
        for ii=1:lenRad
            %distemp=sumsqr(reshape(Apadded(i-w+w:i+w+w,j-w+w:j+w+w,:),[],1)-...
            %reshape(B(i_rdn(ii)-w:i_rdn(ii)+w,j_rdn(ii)-w:j_rdn(ii)+w,:),[],1));
            distemp=distancemex(reshape(Apadded(i-w+w:i+w+w,j-w+w:j+w+w,:),[],1),...
            reshape(B(i_rdn(ii)-w:i_rdn(ii)+w,j_rdn(ii)-w:j_rdn(ii)+w,:),[],1));
            
            if distemp<bestdist
                bestdist=distemp;
                distances(i,j)=bestdist;
                offsets(i,j,:)=[i_rdn(ii)-i j_rdn(ii)-j];
            end
            
        end
                
            
        
      if dispProgress((i-1)*asz(2)+j); fprintf('='); end  
        
    end
end





end
