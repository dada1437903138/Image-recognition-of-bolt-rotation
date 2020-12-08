%%-------------------------------------------------------------------------------%%
%%相对于main函数对极坐标数据进行了高斯滤波，提升精度%%
%%利用角点进行线段分割，取协方差进行特征值分解，求得每条边方向
%%相比上一版本增加了点位筛选
%%重新从每一段直线的质心绘制直线，初步了解到误差椭圆这个概念
%%相比版本4提取出了每个螺栓的转角，利用去除一个最大值，去除一个最小值，然后平均后剔除大于3sigma的值
%%相比版本5进行了整合，代码重构，实现一个最终对比效果
%%相比版本6加入了图片裁剪功能
%%相比refine加入了图片倾斜校正校正功能(使用了Matlab自带函数，校准点为各个连通域中心)
%%对eigdecompose和polarpeak函数重写，序号为2，取消了图片输出功能，降低计算速度
%%修改时间：2020.6.23晚上
%%-------------------------------------------------------------------------------%%
clear;close all;clc;
%dbstop if error
%% 读取图片
srcDir='.\pic5'; %选择保存图片的文件夹名称
files=dir(fullfile(srcDir,'\*.jpg'));  %列出该文件夹下所有.jpg格式的文件
img1_o=im2double(rgb2gray(imread(fullfile(srcDir,'\',files(1).name))));
scale=1;  %用的原大小，且不裁剪图片
img1=imresize(fun_2(img1_o),scale);
img2_o=im2double(rgb2gray(imread(fullfile(srcDir,'\',files(2).name))));
img2=imresize(fun_2(img2_o),scale);
f1 = figure;imshow(img1);
[img1,~] = imcrop(img1);
close;
f2 = figure;imshow(img2);
[img2,~] = imcrop(img2);
close;
% figure,subplot(221);imshow(img1_o);title('原始图片1');
% subplot(222);imshow(img1);title('图片1去高光')
% subplot(223);imshow(img2_o);title('原始图片2');
% subplot(224);imshow(img2);title('图片2去高光');
tic;
%% 图片预处理，二值化+腐蚀膨胀
img1_bw = GetBwImg(img1,0.11,1,39);   %第二个参数thr越小黑色元素越多
img2_bw = GetBwImg(img2,0.11,1,39);
figure,subplot(121);imshow(img1_bw);
subplot(122);imshow(img2_bw);
%% 提取连通域中心坐标
[bound1,cen1] = GetTargetBox_2(img1_bw);    %显示图像和各个连通域的中心
[bound2,cen2] = GetTargetBox_2(img2_bw);
%% 图片倾斜校正
tform = fitgeotrans(cen2,cen1,'NonreflectiveSimilarity');  %这里采用了matlab自带函数
img2_bwreg = imwarp(img2_bw,tform,'FillValues' ,0); %返回被修正的图片2
figure;subplot(2,2,1);imshow(img1_bw);subplot(2,2,2);imshow(img2_bw);
subplot(2,2,3);imshowpair(img1_bw,img2_bw);subplot(2,2,4);imshowpair(img1_bw,img2_bwreg);
cen2_ori = cen2; %储存原来的cen坐标，便于后期绘图
[bound2,cen2] = GetTargetBox_2(img2_bwreg);  %重新计算坐标
%% 提取各个连通域边界的轮廓矢量(近似于链码)
g_1 = boundaries(img1_bw,8);  %返回的g是各个连通域的边界像素坐标,输入的是预处理好的二值图像
g_2 = boundaries(img2_bwreg,8);  
[m1,n1] = size(img1_bw);   %提取两张图片尺寸
[m2,n2] = size(img2_bwreg);
bimg1 = edgsubtract(g_1,m1,n1);  %edgsubtract用于将boundaries的效果转换为图像，仅为显示用
bimg2 = edgsubtract(g_2,m2,n2);
%% 绘图显示轮廓提取效果
% figure;subplot(1,2,1);imshow(bimg1);title('pic1');hold on;
% for i=1:length(cen1)
%     plot(cen1(i,1),cen1(i,2),'+','Color','red');  %注意：plot命令中的x，y坐标是通常人们认为的坐标系，而不是图像坐标系
%     text(cen1(i,1)+20,cen1(i,2)+20,['ID:',num2str(i)],'FontSize',10,'Color','red');
% end    
% axis on;hold off;
% 
% subplot(1,2,2);imshow(bimg2);title('pic2');hold on;
% for i=1:length(cen2)
%     plot(cen2(i,1),cen2(i,2),'+','Color','red');  %注意：plot命令中的x，y坐标是通常人们认为的坐标系，而不是图像坐标系
%     text(cen2(i,1)+20,cen2(i,2)+20,['ID:',num2str(i)],'FontSize',10,'Color','red');
% end    
% axis on;hold off;
%% 极坐标转换
[po_sum1,t1,cen_trans1] = car2pol(bimg1,cen1,bound1);
[po_sum2,t2,cen_trans2] = car2pol(bimg2,cen2,bound2);
%% 寻找极坐标数据极值，(绘制角点结果)     
info1 = polarpeak2(po_sum1,t1,cen_trans1,1);
info2 = polarpeak2(po_sum2,t2,cen_trans2,2);
%% 根据极坐标极值进行各个边缘分段,并转换为笛卡尔坐标系
line1 = segment2car(po_sum1,info1,cen_trans1);
line2 = segment2car(po_sum2,info2,cen_trans2);
%% 进行特征值分解求直线方向向量，(显示提取效果)
direc1 = eigdecompose2(line1,t1,1);
direc2 = eigdecompose2(line2,t2,2);        
%% 计算提取螺栓平均角度
[angel1,rst1,mean_ang1] = calcangel(direc1);
[angel2,rst2,mean_ang2] = calcangel(direc2);
%% 计算转角及结果显示
rotation = mean_ang2-mean_ang1;  %计算对应转角,顺正逆负
rotation = round(rotation,1);
toc;
% rotation(abs(rotation())<=2) = 0;  %筛除转角小于2°的值，此处阈值尚待商榷
figure;subplot(1,2,1);imshow(img1);title('pic1');hold on;
for i = 1:length(cen1)
    plot(cen1(i,1),cen1(i,2),'+');
    text(cen1(i,1)+20,cen1(i,2),['ID:',num2str(i)],'FontSize',10,'Color','red');
end
hold off;
subplot(1,2,2);imshow(img2);title('pic2');hold on;
for i  = 1:length(cen2_ori)
    plot(cen2_ori(i,1),cen2_ori(i,2),'+');
    text(cen2_ori(i,1)+20,cen2_ori(i,2),['ID:',num2str(i),',angel：',num2str(rotation(i))],'FontSize',10,'Color','red');
end
% saveas(gcf,'angel_detected.jpg')


    