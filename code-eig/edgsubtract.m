function bimg=edgsubtract(g,m,n)
%% 显示边界提取效果
%% g：提取的边界轮廓坐标，m，n：二值图像尺寸
bim = cell(1,length(g));
for i = 1:length(g)                  
    xmin=min(g{i}(:,1));                       
    ymin=min(g{i}(:,2));    
    %生成一幅二值图像,大小为m n，xmin,ymin是B4中最小的x和y轴坐标                   
    bim{1,i}=bound2im(g{i},m,n,xmin,ymin);    %将g(坐标信息)转换为二值图面，各个连通域的二值图像
end

bimg = zeros(m,n);      %bim{i}为第i个螺栓边界，下面求和以后可以在同一张图上显示所有螺栓
for k = 1:length(bim) 
    for i = 1:m
        for j = 1:n
            bimg(i,j) = or(bimg(i,j),bim{k}(i,j)); 
        end
    end
end   
