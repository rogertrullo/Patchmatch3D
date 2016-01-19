
function reconstImg=reconstruct(A,B,offsets,w)


fprintf('Reconstructing Output Volume... ');
reconstImg = zeros(size(A));
offsets=offsets+1;
for ii = 1:w:size(A,1)-w+1
    for jj = 1:w:size(A,2)-w+1
        for kk = 1:w:size(A,3)-w+1
        
            reconstImg(ii:ii+w-1,jj:jj+w-1,kk:kk+w-1) = B(offsets(ii,jj,kk,1):offsets(ii,jj,kk,1)+w-1,offsets(ii,jj,kk,2):offsets(ii,jj,kk,2)+w-1,offsets(ii,jj,kk,3):offsets(ii,jj,kk,3)+w-1,offsets(ii,jj,kk,4));
        
        end
    end
end
fprintf('Done!\n');

%imagen=uint8(reconstImg);
%imshow(imagen)

end