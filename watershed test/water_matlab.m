rgb = imread('pears.png');%��ȡԭͼ��
I = rgb2gray(rgb);%ת��Ϊ�Ҷ�ͼ��
figure; subplot(121)%��ʾ�Ҷ�ͼ��
imshow(I)
text(732,501,'Image courtesy of Corel',...
     'FontSize',7,'HorizontalAlignment','right')
hy = fspecial('sobel');%sobel����
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');%�˲���y�����Ե
Ix = imfilter(double(I), hx, 'replicate');%�˲���x�����Ե
gradmag = sqrt(Ix.^2 + Iy.^2);%����
subplot(122); imshow(gradmag,[]), %��ʾ�ݶ�
title('Gradient magnitude (gradmag)')

%2. ֱ��ʹ���ݶ�ģֵ���з�ˮ���㷨������������ڹ��ķָ�������Ч�����ã�

L = watershed(gradmag);%ֱ��Ӧ�÷�ˮ���㷨
Lrgb = label2rgb(L);%ת��Ϊ��ɫͼ��
figure; imshow(Lrgb), %��ʾ�ָ���ͼ��
title('Watershed transform of gradient magnitude (Lrgb)')

%3.�ֱ��ǰ���ͱ������б�ǣ�������ʹ����̬ѧ�ؽ�������ǰ��������б�ǣ�����ʹ�ÿ�������������֮�����ȥ��һЩ��С��Ŀ�ꡣ

se = strel('disk', 20);%Բ�νṹԪ��
Io = imopen(I, se);%��̬ѧ������
figure; subplot(121)
imshow(Io), %��ʾִ�п��������ͼ��
title('Opening (Io)')
Ie = imerode(I, se);%��ͼ����и�ʴ
Iobr = imreconstruct(Ie, I);%��̬ѧ�ؽ�
subplot(122); imshow(Iobr), %��ʾ�ؽ����ͼ��
title('Opening-by-reconstruction (Iobr)')
Ioc = imclose(Io, se);%��̬ѧ�ز���
figure; subplot(121)
imshow(Ioc), %��ʾ�ز������ͼ��
title('Opening-closing (Ioc)')
Iobrd = imdilate(Iobr, se);%��ͼ���������
Iobrcbr = imreconstruct(imcomplement(Iobrd), ...
    imcomplement(Iobr));%��̬ѧ�ؽ�
Iobrcbr = imcomplement(Iobrcbr);%ͼ����
subplot(122); imshow(Iobrcbr), %��ʾ�ؽ��󷴺��ͼ��
title('Opening-closing by reconstruction (Iobrcbr)')
fgm = imregionalmax(Iobrcbr);%�ֲ�����ֵ
figure; imshow(fgm), %��ʾ�ؽ���ֲ�����ֵͼ��
title('Regional maxima of opening-closing by reconstruction (fgm)')
I2 = I;
I2(fgm) = 255;%�ֲ�����ֵ������ֵ��Ϊ255
figure; imshow(I2), %��ԭͼ����ʾ����ֵ����
title('Regional maxima superimposed on original image (I2)')
se2 = strel(ones(5,5));%�ṹԪ��
fgm2 = imclose(fgm, se2);%�ز���
fgm3 = imerode(fgm2, se2);%��ʴ
fgm4 = bwareaopen(fgm3, 20);%������
I3 = I;
I3(fgm4) = 255;%ǰ��������Ϊ255
figure; subplot(121)
imshow(I3)%��ʾ�޸ĺ�ļ���ֵ����
title('Modified regional maxima')
bw = im2bw(Iobrcbr, graythresh(Iobrcbr));%ת��Ϊ��ֵͼ��
subplot(122); imshow(bw), %��ʾ��ֵͼ��
title('Thresholded opening-closing by reconstruction')

%4. ���з�ˮ��任����ʾ��

D = bwdist(bw);%�������
DL = watershed(D);%��ˮ��任
bgm = DL == 0;%��ȡ�ָ�߽�
figure; imshow(bgm), %��ʾ�ָ��ı߽�
title('Watershed ridge lines (bgm)')
gradmag2 = imimposemin(gradmag, bgm | fgm4);%����Сֵ
L = watershed(gradmag2);%��ˮ��任
I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;%ǰ�����߽紦��255
figure; subplot(121)
imshow(I4)%ͻ��ǰ�����߽�
title('Markers and object boundaries')
Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');%ת��Ϊα��ɫͼ��
subplot(122); imshow(Lrgb)%��ʾα��ɫͼ��
title('Colored watershed label matrix')
figure; imshow(I),
hold on
himage = imshow(Lrgb);%��ԭͼ����ʾα��ɫͼ��
set(himage, 'AlphaData', 0.3);
title('Lrgb superimposed transparently on original image')