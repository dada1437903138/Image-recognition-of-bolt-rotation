function line = segment2car(po_sum,info,cen_trans)
%% 根据极坐标极值进行各个边缘分段,在空域上进行分段很容易出现问题
%% 输入po_sum为一张总图中各个连通域的轮廓极坐标序列，info为各个轮廓角点极坐标
%% 返回的line即为根据角点分段后的各线段笛卡尔坐标系
po_line = cell(length(po_sum),length(info(1).loc));  %这里预分配内存的时候length(info(i).loc)本应该随着i不同而不同，但在这里都是提取六个边的，所以就图省事了
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
line = cell(m,n);
for i = 1:m
    for j = 1:n
        if ~isempty(po_line{i,j})  %防止出现峰值点提取不到导致边线少于6跟
            line{i,j}(:,1) = cen_trans(i,1)+po_line{i,j}(:,1).*cos(po_line{i,j}(:,2)/360*2*pi);  %数列间的乘法注意用点乘
            line{i,j}(:,2) = cen_trans(i,2)-po_line{i,j}(:,1).*sin(po_line{i,j}(:,2)/360*2*pi);   %注意图像坐标轴正负
        end
    end
end