function [po_sum,t,cen_trans] = car2pol(bimg,cen,bound,process)
%% 将螺栓轮廓上各个像素点的空间坐标转换为极坐标
%% 输入根据轮廓矢量提取到的二值边缘图像，连通域中心、方框
%%输出的是各个轮廓边线的theta-rho坐标,以及裁剪过的单独图片,中心坐标
%%process为1则输出提取极坐标过程，不输或者为0则不显示图片

if nargin < 4
    process = 0;  %设置默认值为不显示提取过程
end

cen_trans = zeros(length(bound),2);  %得到单个螺栓图片中心位置坐标
%计算出各个裁剪图片的中心坐标
for i = 1:length(bound)
    cen_trans(i,1) = cen(i,1)-bound(i,1)+10;   %10是裁剪螺栓图片时的预留边界
    cen_trans(i,2) = cen(i,2)-bound(i,2)+10;   %cen_trans的x，y是普通坐标系的，而非图像坐标系
end

%创建一个显示提取点的图窗=================
if process
    figure; 
end
%========================================

t = cell(1,length(bound)); %预分配内存
for i = 1:length(bound)
    t{i}=bimg(round(bound(i,2)-10):round(bound(i,2)+bound(i,4)+10),round(bound(i,1)-10):round(bound(i,1)+bound(i,3)+10));%t是各个裁剪后照片的子图片
    [m,n]=size(t{i});  %获取单个螺栓照片的尺寸
    a=1;
%   polar = struct('rho',{},'theta',{}); %预分配内存,具体rho和theta的值仍然未知
%   polar = repmat(polar,1,length(bound)); %仍然不太会为结构与预分配内存

    %画图显示扫描过程===================================================
    if process
        subplot(1,2,1);imshow(t{i});title(['no: ',num2str(i)]); hold on;
    end
    %==================================================================
    
    %开始扫描像素
    for x =1:m   %mm是行数，nn是列数,这里的x,y是图像坐标系的，和下面cen_trans做运算时注意转换
        for y =1:n
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
                
                %画图显示扫描过程=========================================
                if process
                    subplot(1,2,1);plot(y,x,'o','Color','g');    %在原图绘制点
                    subplot(1,2,2);plot(polar(i).theta(a)*360/(2*pi),polar(i).rho(a),'*','color','R');hold on;  %绘制极坐标曲线图
                    pause(0.002);
                end
                %========================================================
                a=a+1;
            end
        end
    end
    %==============
    if process
        hold off;
    end
    %==============
end

%% 重新整理换算得到的极坐标数据，将角度按0-360度排列，为下一步做准备
po_sum = cell(1,length(polar));
for i = 1:length(polar)
    po = cat(1,polar(i).rho,polar(i).theta);
    po = sortrows(po',2);
    po = cat(2,po(:,1),po(:,2)*360/(2*pi));
    po_sum{i} = po;
end