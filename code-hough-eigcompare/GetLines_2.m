function lines=GetLines_2(t,FillGap,MinLength)
Iedge=edge(t,'canny');  %此处canny算子阈值自动设置了，可以手动优化
Iedge=bwmorph(Iedge,'thin',Inf);
%%进行霍夫变换
[H, theta , rho] = hough (Iedge);
%%峰值
P = houghpeaks(H,6,'threshold',0.2*max(H(:)));   %默认是0.5，算是检测灵敏度阈值吧
%The function returns peaks a matrix that holds the row and column coordinates of the peaks.
x = theta(P(:,2));
y = rho(P(:,1));   %这是参数空间中提取出的点坐标
lines = houghlines(Iedge,theta,rho,P,'FillGap',FillGap,'MinLength',MinLength);
%extracts line segments in the image BW associated with particular bins in a Hough transform
%返回的信息包括每条线的终点起点、theta、rho
%The return value lines is a structure array whose length equals the number of merged line segments found.
%'FillGap'：When the distance between the line segments is less than the value specified, 
%the houghlines function merges the line segments into a single line segment.
%'MinLength'discards lines that are shorter than the value specified.

%%  去掉重复的直线
slope=0;
distance=0;
len=length(lines);
for k = 1:len
    xy = [lines(k).point1;lines(k).point2]; %lines中两个端点坐标，xy形成一个4*4矩阵
    slope(k)=(xy(1,1) - xy(2,1))/(xy(1,2) - xy(2,2));
    if slope(k)>1    %
        slope(k)=1/slope(k);   
    end
    distance(k)=(xy(1,1) - xy(2,1))^2 + (xy(1,2) - xy(2,2))^2;
end
%存下每条线的斜率和长度
N=length(slope);   %和len是一样的
a=repmat(slope,N,1);  %repmat是复制矩阵
b=repmat(slope',1,N); %ab转置关系
var_slope=abs(a-b);   %
var_slope(var_slope==0)=100;   %var_slope=0意味着完全不重合
var_slope2=unique(var_slope);  %提取出var_slope所有元素组成向量（去掉重复的）

del_index=[];
i=1;
temp=find(var_slope2<0.2);    %find返回的是索引值
if ~isempty(temp)  %如果temp不为空，~是取反
    for k=1:length(temp)
        index=find(var_slope==var_slope2(temp(k)));
        index=index(1);        
        [ind1,ind2]=ind2sub(size(var_slope),index);        
        xy1 = [lines(ind1).point1];
        xy2 = [lines(ind2).point1];
        if(sqrt((xy1(1,1) - xy2(1,1))^2 + (xy1(1,2) - xy2(1,2))^2))<50.0
            [~,index]=min([distance(ind1),distance(ind2)]);
            if index==1
               del_index(i)=ind1;
               i=i+1;
            else
                 del_index(i)=ind2;
               i=i+1;
            end
        end
    end
end
if ~isempty(del_index)
    b=unique(del_index);
    b=sort(b,'descend');
    for k=1:length(b)
        lines(b(k))=[];
    end
end

