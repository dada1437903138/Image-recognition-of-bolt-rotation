function [bound,cen]=GetTargetBox_2(img_bw)
%% 该函数需要根据不同排布的螺栓形式进行修改
[L, ~] = bwlabel(img_bw);%对二值图进行标记  默认的为8连通域查找，L为返回的连通域图像
%figure;imagesc(L)   %imagesc和colormap有关
%对二值图中的各个连通域进行特征提取
stats=regionprops(L,'Area','Centroid','BoundingBox');  %用来度量图像区域属性的函数，使用前要先bwlabel
%'Area'是标量，计算出在图像各个区域中像素总个数；
%'Centroid'是1行ndims(L)列的向量，给出每个区域的质心（重心）。
%注意：Centroid 的第一个元素是重心水平坐标（x坐标）、第二个元素是重心垂直坐标（y坐标）
%'BoundingBox' 是1行ndims(L)*2列的向量,即包含相应区域的最小矩形 包括矩形左上角坐标和长宽
cen = cat(1,stats.Centroid);%连通域中心坐标  cat(1,...)按列连接数组  cen即为各个连通域的中心坐标
BoundingBox = cat(1, stats.BoundingBox);%外接边框    不用cat提取不出来
%% 对数据按照先列后行的顺序排序，以方便左右螺帽的对应
% bound=sortrows(BoundingBox,[1,2]);  %将坐标按照从左到右、从上到下的顺序进行排序，这样证明无效，还是要分段排序
% cen=sortrows(cen,[1,2]);

%%注意，bound和cen分开排序的话很有可能出现错误

cenl=sortrows(cen(1:4,:),2);
cenr=sortrows(cen(5:end,:),2);
cen=[cenl;cenr];
bl=sortrows(BoundingBox(1:4,:),2);      %sortrow：按照y坐标的顺序提取       %%这里随螺栓排布不同而改变
br=sortrows(BoundingBox(5:end,:),2);    %把左右两列螺栓群的外框坐标和长宽提出来
bound=[bl;br];