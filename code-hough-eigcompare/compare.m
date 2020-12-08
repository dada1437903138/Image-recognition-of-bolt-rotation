%%-------------------------------------------------------------------------------%%
%%相对于main函数对极坐标数据进行了高斯滤波，提升精度%%
%%利用角点进行线段分割，取协方差进行特征值分解，求得每条边方向
%%相比上一版本增加了点位筛选
%%重新从每一段直线的质心绘制直线，初步了解到误差椭圆这个概念
%%相比版本4提取出了每个螺栓的转角，利用去除一个最大值，去除一个最小值，然后平均后剔除大于3sigma的值
%%修改时间：2020.6.19下午
%%-------------------------------------------------------------------------------%%

clear;close all;clc;
%dbstop if error
img = im2bw(imread('1.jpg'));
g = boundaries(img,8);  %返回的g是各个连通域的边界像素坐标
[m,n]=size(img); %求二值图像的大小
%% 显示边界提取效果
for i = 1:length(g)                  
    xmin=min(g{i}(:,1));                       
    ymin=min(g{i}(:,2));    
    %生成一幅二值图像,大小为m n，xmin,ymin是B4中最小的x和y轴坐标                   
    bim{i}=bound2im(g{i},m,n,xmin,ymin);    %将g(坐标信息)转换为二值图面，各个连通域的二值图像
end

bimg = zeros(m,n);      %bim{i}为第i个螺栓边界，下面求和以后可以在同一张图上显示所有螺栓
for k = 1:length(bim) 
    for i = 1:m
        for j = 1:n
            bimg(i,j) = or(bimg(i,j),bim{k}(i,j)); 
        end
    end
end   

%% 提取各个连通域边界的链码信息

[bound,cen]=GetTargetBox_2(img);    %显示图像和各个连通域的中心

%% 极坐标转换
cen_trans = zeros(length(bound),2);  %得到单个螺栓图片中心位置坐标
for i = 1:length(bound)
    cen_trans(i,1) = cen(i,1)-bound(i,1)+10;   %10是裁剪螺栓图片时的预留边界
    cen_trans(i,2) = cen(i,2)-bound(i,2)+10;   %cen_trans的x，y是普通坐标系的，而非图像坐标系
end

for i = 1:length(bound)
    t{i}=bimg(round(bound(i,2)-10):round(bound(i,2)+bound(i,4)+10),round(bound(i,1)-10):round(bound(i,1)+bound(i,3)+10));%t是各个裁剪后照片的子图片
    [mm,nn]=size(t{i});  %获取单个螺栓照片的尺寸
    a=1;
    
    for x =1:mm   %mm是行数，nn是列数,这里的x,y是图像坐标系的，和下面cen_trans做运算时注意转换
        for y =1:nn
            if t{i}(x,y) ==1  %如果这一点为1，即存在像素
                polar(i).rho(a) = norm([y,x]-cen_trans(i,:));
                if x>=cen_trans(i,2)           %角度分四个象限算，可以看画的图，坐标换算比较绕，这里的象限指普通象限，我把图像坐标显示打开了具体可以看
                    if y>=cen_trans(i,1)
                        polar(i).theta(a)=2*pi-asin((x-cen_trans(i,2))/polar(i).rho(a));
                    elseif y<cen_trans(i,1)
                        polar(i).theta(a)=pi+asin((x-cen_trans(i,2))/polar(i).rho(a));
                    end
                end
                
                if x<cen_trans(i,2)
                    if y>=cen_trans(i,1)
                        polar(i).theta(a)=asin((cen_trans(i,2)-x)/polar(i).rho(a));
                    elseif y<cen_trans(i,1)
                        polar(i).theta(a)=pi-asin((cen_trans(i,2)-x)/polar(i).rho(a));
                    end
                end   
                a=a+1;   
            end
        end
    end
end

%% 重新整理换算得到的极坐标数据，为下一步做准备
for i = 1:length(polar)
    po = cat(1,polar(i).rho,polar(i).theta);
    po = sortrows(po',2);
    po = cat(2,po(:,1),po(:,2)*360/(2*pi));
    po_sum{i} = po;
end

%% 寻找极坐标数据极值，并绘制结果
for i = 1:length(po_sum)
    %汇出极坐标曲线图，平滑并寻找极大值
    smoth = smoothdata(po_sum{i}(:,1),'gaussian',12);  %对y轴值做高斯平滑
    [maxv,maxl] = findpeaks(smoth,'minpeakdistance',16); %maxv峰峰值点  maxl：峰峰值点对应的位置   最小间隔=15 
    te2 = po_sum{i}(:,1);  %te,te2均为临时变量
    maxv = te2(maxl);  %前面的maxv是高斯平滑后的max值，此处利用loc信息寻找实际曲线上对应的值
    te = po_sum{i}(:,2);
    maxl = te([maxl],1);  %最大rho对应的角度坐标
    info(i).loc = maxl;  %info里包含了各个螺栓的峰值信息
    info(i).val = maxv;
end

%% 根据极坐标极值进行各个边缘分段,在空域上进行分段很容易出现问题
for i = 1:length(po_sum)  %遍历各个螺栓
    for j = 1:length(info(i).loc) %遍历各个极值点,顺序为1-2，2-3，3-4，4-5，5-6，6-1
        if j <= length(info(i).loc)-1
            ind = find(po_sum{i}(:,2)>=info(i).loc(j) & po_sum{i}(:,2)<info(i).loc(j+1));  %返回两个峰值点间所有像素点的坐标
            temp = po_sum{i}(:,1); %中间变量
            temp2 = po_sum{i}(:,2);
            po_line{i,j}(:,1) = temp(ind);  %储存这些中间点的tho
            po_line{i,j}(:,2) = temp2(ind); %储存这些中间点的theta
        elseif j == length(info(i).loc) %当遍历到最后一个边的时候
            ind = find(po_sum{i}(:,2)>=info(i).loc(j) | po_sum{i}(:,2)<info(i).loc(1));  %返回大于6小于1之间的所有像素点的坐标
            temp = po_sum{i}(:,1); %中间变量
            temp2 = po_sum{i}(:,2);
            po_line{i,j}(:,1) = temp(ind);  %储存这些中间点的tho       行数代表螺栓，列数代表提取出的各个边
            po_line{i,j}(:,2) = temp2(ind);  %储存这些中间点的theta
        end
    end
end

%% 将提取出的各个线段转换为笛卡尔坐标系
% 得到的line中的坐标为通用坐标，图像坐标系中x，y要调换
[m,n] = size(po_line);
for i = 1:m
    for j = 1:n
        line{i,j}(:,1) = cen_trans(i,1)+po_line{i,j}(:,1).*cos(po_line{i,j}(:,2)/360*2*pi);  %数列间的乘法注意用点乘
        line{i,j}(:,2) = cen_trans(i,2)-po_line{i,j}(:,1).*sin(po_line{i,j}(:,2)/360*2*pi);   %注意图像坐标轴正负
    end
end

%进行特征值分解求直线方向向量，并显示提取效果
figure;
for i = 1:length(t)
    [m,n] = size(t{i});
    tesimg{i} = zeros(m,n);  %创建出每个图片的空矩阵
    for j = 1:size(line,2)
        pos = round(line{i,j});  %将图像坐标转换为像素坐标的整数
        tesimg{i}(sub2ind(size(t{i}),pos(:,2),pos(:,1)))=1;  %注意pos里的是通用坐标系，转换为图像时x，y要调换  sub2ind很好用
    end
    subplot(2,4,i);imshow(tesimg{i});axis on;title(['no:',num2str(i)]);hold on;  %先画出螺栓
    %hough transform
    xy1=GetLines_2(t{i},40,10);  %提取霍夫变换
    for j=1:length(xy1)
        points = [xy1(j).point1; xy1(j).point2];
        plot(points(:,1),points(:,2),'LineWidth',2,'Color','yellow');
        plot(points(1,1),points(1,2),'x','LineWidth',2,'Color','yellow');
        plot(points(2,1),points(2,2),'x','LineWidth',2,'Color','red');
    end
    
    for j = 1:size(line,2)
           line{i,j} = sortrows(line{i,j},[2,1],'descend');  %首先根据y坐标由大到小的顺序，然后根据x坐标，对所有点重新排序
           %去除误差------------------------------------------
           covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
           [V,D] = eig(covariance);
           std_line = line{i,j}-mean(line{i,j});  %为后来计算投影做准备
           st = 3*sqrt(D(1,1));  %d2开根号就是这个方向上的标准差，剔除超过3sigma的点
           clear cast;
           for k =1:length(std_line)
               cast(k)=std_line(k,:)*V(:,1); %计算每个点在法向量上的投影
           end
           cast = cast';
           ind = find(abs(cast)>st); %找出投影中大于3sigma的点
           line{i,j}(ind,:) = [];  %去除投影中大于3sigma的点
           %--------------------------------------------------
           covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
           [V,D] = eig(covariance);  %重新计算协方差，并进行特征值分解
           direc{i,j} = V(:,2); %储存方向向量，为计算角度做准备
           temp = mean(line{i,j});
           dis = 12; %随便定的一个值，画起来好看一点
           x1 = temp(1,1)+V(1,2)*ceil(dis);  %从质心和方向向量推算出的直线端点坐标
           y1 = temp(1,2)+V(2,2)*ceil(dis);
           x2 = temp(1,1)-V(1,2)*ceil(dis);
           y2 = temp(1,2)-V(2,2)*ceil(dis);
           plot(x1,y1,'o','Color','yellow'); %绘制出eig分解后由线段质心推算出的线段端点
           plot(x2,y2,'o','Color','yellow'); %绘制出eig分解后由线段质心推算出的线段端点
           plot([x1,x2],[y1,y2],'LineWidth',2,'Color','red');
    end
end





    