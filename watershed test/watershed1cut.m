f=rgb2gray(imread('pears.png'));
subplot(2,3,1);
imshow(f);
f=double(f);
hv=fspecial('prewitt');
hh=hv.';
gv=abs(imfilter(f,hv,'replicate'));
gh=abs(imfilter(f,hh,'replicate'));
g=sqrt(gv.^2+gh.^2);

subplot(2,3,2);
df=bwdist(f);
imshow(uint8(df*8));
title('distance change');
L=watershed(df);
em=L==0;
subplot(2,3,3);
imshow(em);
title('sign extend limint');
im = imextendedmax(f,20);
subplot(2,3,4);
imshow(im);
title('sign intend limit');
g2=imimposemin(g,im|em);
subplot(2,3,5);
imshow(g2);
L2=watershed(g2);
wr2=L2==0;
subplot(2,3,6);
f(wr2)=255;
imshow(uint8(f));