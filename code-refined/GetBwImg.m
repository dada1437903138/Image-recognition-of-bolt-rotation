function bw=GetBwImg(img,thr,id,selen)
%% ��ȡ��ֵͼ��
if id==1 
    img_bw=im2bw(img,thr);  %thrԽС��ɫԪ��Խ��
    img_bw=~img_bw;  %��÷���ͼƬ
    se=strel('octagon',selen);  %�������͸�ʴ����������˵���״�ʹ�С  
    %������ȥ��������Ԫ�أ����ɫ�������ӵ�����Ԫ�أ����ɫ��
    %������ȥ��������Ԫ�أ����ɫ�������Ӹ�����Ԫ�أ����ɫ��
    %��ʴ����������Ҫ����ȥ����㣬������ʧͼƬ������
    %SE = strel('octagon',r) creates a octagonal structuring element, 
    %where r specifies the distance from the structuring element origin to
    %the sides of the octagon, as measured along the horizontal and vertical axes.
    %r must be a nonnegative multiple of 3.
    img_bw=imclose(img_bw,se);  %���б����㣨�����ͺ�ʴ��һ�㾭�����п�������
    bw=imfill(img_bw,'holes');  %����ֵͼ���еĿն�����
else  
    img_bw=im2bw(img,thr);      %����ͼ����Ĺ���
    se=strel('octagon',selen);
    img_bw=imclose(img_bw,se);
    bw=imfill(img_bw,'holes');
end