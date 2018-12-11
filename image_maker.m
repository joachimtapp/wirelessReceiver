function [bitstream,imsize] = image_maker(image)
    imdata = imread(image);
    I = rgb2gray(imdata);
    imsize=size(I);
%     figure()
%     imshow(I,[])
%     truesize([500 500]);
%     movegui('west')
%     title('original')
    for i=1:imsize(1)
        for j=1:imsize(2)
           bitstream(i+length(I)*(j-1))=I(i,j) ;

        end
    end

    bitstream=de2bi(bitstream,'left-msb');
    bitstream=reshape(bitstream.',[8*length(bitstream),1]);
end