%%-------------------------------------------------------------------------------%%
%%�����main�����Լ��������ݽ����˸�˹�˲�����������%%
%%���ýǵ�����߶ηָȡЭ�����������ֵ�ֽ⣬���ÿ���߷���
%%�����һ�汾�����˵�λɸѡ
%%���´�ÿһ��ֱ�ߵ����Ļ���ֱ�ߣ������˽⵽�����Բ�������
%%��Ȱ汾4��ȡ����ÿ����˨��ת�ǣ�����ȥ��һ�����ֵ��ȥ��һ����Сֵ��Ȼ��ƽ�����޳�����3sigma��ֵ
%%��Ȱ汾5���������ϣ������ع���ʵ��һ�����նԱ�Ч��
%%��Ȱ汾6������ͼƬ�ü�����
%%���refine������ͼƬ��бУ��У������(ʹ����Matlab�Դ�������У׼��Ϊ������ͨ������)
%%��eigdecompose��polarpeak������д�����Ϊ2��ȡ����ͼƬ������ܣ����ͼ����ٶ�
%%����ֵ��ֵ���㲻Ӯ��matlab�Դ���watershed�����ã���ʱ��ͼƬ��imagepy��up down watershedԤ����
%%��ȡpy�ļ������ͼƬ
%%�޸�ʱ�䣺2020.6.24����
%%-------------------------------------------------------------------------------%%
clear;close all;clc;
%dbstop if error
%% ��ȡͼƬ
srcDir='.\py2'; %ѡ�񱣴�ͼƬ���ļ�������
files=dir(fullfile(srcDir,'\*.jpg'));  %�г����ļ���������.jpg��ʽ���ļ�
img1_o=im2bw(imread(fullfile(srcDir,'\',files(1).name)));
img2_o=im2bw(imread(fullfile(srcDir,'\',files(2).name)));
scale=1;  %�õ�ԭ��С���Ҳ��ü�ͼƬ
img1=imresize(img1_o,scale);
img2=imresize(img2_o,scale);
f1 = figure;imshow(img1);
[img1,~] = imcrop(img1);
close;
f2 = figure;imshow(img2);
[img2,~] = imcrop(img2);
close;
% figure,subplot(221);imshow(img1_o);title('ԭʼͼƬ1');
% subplot(222);imshow(img1);title('ͼƬ1ȥ�߹�')
% subplot(223);imshow(img2_o);title('ԭʼͼƬ2');
% subplot(224);imshow(img2);title('ͼƬ2ȥ�߹�');
%% ͼƬԤ��������ֵ��+��ʴ����
% img1_bw = GetBwImg(img1,0.18,1,9);   %�ڶ�������thrԽС��ɫԪ��Խ��
% img2_bw = GetBwImg(img2,0.2,1,3);
% figure,subplot(121);imshow(img1_bw);
% subplot(122);imshow(img2_bw);
%% ��ȡ��ͨ����������
[bound1,cen1] = GetTargetBox_2(img1);    %��ʾͼ��͸�����ͨ�������
[bound2,cen2] = GetTargetBox_2(img2);
%% ͼƬ��бУ��
tform = fitgeotrans(cen2,cen1,'NonreflectiveSimilarity');  %���������matlab�Դ�����
img2_bwreg = imwarp(img2,tform,'FillValues' ,0); %���ر�������ͼƬ2
%figure;subplot(2,2,1);imshow(img1_bw);subplot(2,2,2);imshow(img2_bw);
%subplot(2,2,3);imshowpair(img1_bw,img2_bw);subplot(2,2,4);imshowpair(img1_bw,img2_bwreg);
cen2_ori = cen2; %����ԭ����cen���꣬���ں��ڻ�ͼ
[bound2,cen2] = GetTargetBox_2(img2_bwreg);  %���¼�������
%% ��ȡ������ͨ��߽������ʸ��(����������)
g_1 = boundaries(img1,8);  %���ص�g�Ǹ�����ͨ��ı߽���������,�������Ԥ�����õĶ�ֵͼ��
g_2 = boundaries(img2_bwreg,8);  
[m1,n1] = size(img1);   %��ȡ����ͼƬ�ߴ�
[m2,n2] = size(img2_bwreg);
bimg1 = edgsubtract(g_1,m1,n1);  %edgsubtract���ڽ�boundaries��Ч��ת��Ϊͼ�񣬽�Ϊ��ʾ��
bimg2 = edgsubtract(g_2,m2,n2);
%% ��ͼ��ʾ������ȡЧ��
% figure;subplot(1,2,1);imshow(bimg1);title('pic1');hold on;
% for i=1:length(cen1)
%     plot(cen1(i,1),cen1(i,2),'+','Color','red');  %ע�⣺plot�����е�x��y������ͨ��������Ϊ������ϵ��������ͼ������ϵ
%     text(cen1(i,1)+20,cen1(i,2)+20,['ID:',num2str(i)],'FontSize',10,'Color','red');
% end    
% axis on;hold off;
% 
% subplot(1,2,2);imshow(bimg2);title('pic2');hold on;
% for i=1:length(cen2)
%     plot(cen2(i,1),cen2(i,2),'+','Color','red');  %ע�⣺plot�����е�x��y������ͨ��������Ϊ������ϵ��������ͼ������ϵ
%     text(cen2(i,1)+20,cen2(i,2)+20,['ID:',num2str(i)],'FontSize',10,'Color','red');
% end    
% axis on;hold off;
%% ������ת��
[po_sum1,t1,cen_trans1] = car2pol(bimg1,cen1,bound1);
[po_sum2,t2,cen_trans2] = car2pol(bimg2,cen2,bound2);
%% Ѱ�Ҽ��������ݼ�ֵ��(���ƽǵ���)     
info1 = polarpeak2(po_sum1,t1,cen_trans1,1);
info2 = polarpeak2(po_sum2,t2,cen_trans2,2);
%% ���ݼ����꼫ֵ���и�����Ե�ֶ�,��ת��Ϊ�ѿ�������ϵ
line1 = segment2car(po_sum1,info1,cen_trans1);
line2 = segment2car(po_sum2,info2,cen_trans2);
%% ��������ֵ�ֽ���ֱ�߷���������(��ʾ��ȡЧ��)
direc1 = eigdecompose2(line1,t1,1);
direc2 = eigdecompose2(line2,t2,2);        
%% ������ȡ��˨ƽ���Ƕ�
[angel1,rst1,mean_ang1] = calcangel(direc1);
[angel2,rst2,mean_ang2] = calcangel(direc2);
%% ����ת�Ǽ������ʾ
rotation = mean_ang2-mean_ang1;  %�����Ӧת��,˳���渺
rotation = round(rotation,1);
rotation(abs(rotation())<=2) = 0;  %ɸ��ת��С��2���ֵ���˴���ֵ�д���ȶ
figure;subplot(1,2,1);imshow(img1);title('pic1');hold on;
for i = 1:length(cen1)
    plot(cen1(i,1),cen1(i,2),'+');
    text(cen1(i,1)+20,cen1(i,2),['ID:',num2str(i)],'FontSize',10,'Color','red');
end
hold off;
subplot(1,2,2);imshow(img2);title('pic2');hold on;
for i  = 1:length(cen2_ori)
    plot(cen2_ori(i,1),cen2_ori(i,2),'+');
    text(cen2_ori(i,1)+20,cen2_ori(i,2),['ID:',num2str(i),',angel��',num2str(rotation(i))],'FontSize',10,'Color','red');
end
% saveas(gcf,'angel_detected.jpg')


    