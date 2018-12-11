function [] = image_reader(bitstream,shape)
% bitstream=[1 0 0 0 0 0 0 0 1 0 1 0 1 0 1 0 0 0 1 1 0 0 1 0 0 0 0 0 0 0 0 1 ]';
% shape=[2,2];
bin=reshape(bitstream,8,[])';
dec=bi2de(bin,'left-msb')';


for i=1:shape(1)
    for j=1:shape(2)
       im(i,j)=dec(i+(j-1)*shape(1));
    end
end
subplot(2,1,2);
imshow(im,[])
truesize([500 500]);
title('received')
 movegui('east')
end

