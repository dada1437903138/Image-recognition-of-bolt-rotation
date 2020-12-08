function [angel,rst,mean_ang] = calcangel(direc)
%% 输入direc:每个边线的方向向量
%% 输出angel:每个边线的换算角度  rst:储存了剔除最值后的中间结果，不用于输出，用于debug    mean_angel:平均各个边线算下来的转角
angel = zeros(size(direc,1),size(direc,2));
rst = cell(1,length(direc));
mean_ang = zeros(1,length(direc));
for i = 1:length(direc)
    for j = 1:length(direc(i,:))
        temp = direc{i,j};
        if temp(1,1) >= 0  %根据象限计算角度，以x轴向y轴旋转方向为正，具体示意见ipad画的图
            if temp(2,1) >= 0  %向量落在图像坐标系第一象限
                angel(i,j) = acos(temp(1,1)/norm(temp))*360/2/pi;  %d=(x,y),则与x轴正向的夹角余弦值：cosa=x/sqrt(x^2+y^2)
            elseif temp(2,1) < 0  %向量落在图像坐标系第四象限
                angel(i,j) = (2*pi-acos(temp(1,1)/norm(temp)))*360/2/pi;
            end
        elseif temp(1,1) < 0
            if temp(2,1) >= 0  %向量落在图像坐标系第二象限
                angel(i,j) = (pi-acos(abs(temp(1,1))/norm(temp)))*360/2/pi;
            elseif temp(2,1) < 0  %向量落在图像坐标系第三象限
                angel(i,j) = (pi+acos(abs(temp(1,1))/norm(temp)))*360/2/pi;
            end 
        end
        angel(i,j) = rem(angel(i,j),60);
    end
    %每条直线的角度剔除一个最大值，剔除一个最小值
    angel_temp = sort(angel(i,:),'descend'); 
    angel_temp(1) = [];
    angel_temp(length(angel_temp)) = [];  %剔除最大、最小值
    sd = std(angel_temp);   %因为只能提取到约6个角度，所以小样本用正态分布剔除3sigma值的方法并不好用
    me = mean(angel_temp);
    ind = find(angel(i,:)<me-3*sd|angel(i,:)>me+3*sd);
    angel_temp = angel(i,:);
    angel_temp(ind) = [];
    rst{i} = angel_temp;  %储存了剔除最值后的中间结果
    mean_ang(i) = mean(angel_temp);
end