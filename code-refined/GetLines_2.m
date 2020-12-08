function lines=GetLines_2(t,FillGap,MinLength)
Iedge=edge(t,'canny');  %�˴�canny������ֵ�Զ������ˣ������ֶ��Ż�
Iedge=bwmorph(Iedge,'thin',Inf);
%%���л���任
[H, theta , rho] = hough (Iedge);
%%��ֵ
P = houghpeaks(H,6,'threshold',0.2*max(H(:)));   %Ĭ����0.5�����Ǽ����������ֵ��
%The function returns peaks a matrix that holds the row and column coordinates of the peaks.
x = theta(P(:,2));
y = rho(P(:,1));   %���ǲ����ռ�����ȡ���ĵ�����
lines = houghlines(Iedge,theta,rho,P,'FillGap',FillGap,'MinLength',MinLength);
%extracts line segments in the image BW associated with particular bins in a Hough transform
%���ص���Ϣ����ÿ���ߵ��յ���㡢theta��rho
%The return value lines is a structure array whose length equals the number of merged line segments found.
%'FillGap'��When the distance between the line segments is less than the value specified, 
%the houghlines function merges the line segments into a single line segment.
%'MinLength'discards lines that are shorter than the value specified.

%%  ȥ���ظ���ֱ��
slope=0;
distance=0;
len=length(lines);
for k = 1:len
    xy = [lines(k).point1;lines(k).point2]; %lines�������˵����꣬xy�γ�һ��4*4����
    slope(k)=(xy(1,1) - xy(2,1))/(xy(1,2) - xy(2,2));
    if slope(k)>1    %
        slope(k)=1/slope(k);   
    end
    distance(k)=(xy(1,1) - xy(2,1))^2 + (xy(1,2) - xy(2,2))^2;
end
%����ÿ���ߵ�б�ʺͳ���
N=length(slope);   %��len��һ����
a=repmat(slope,N,1);  %repmat�Ǹ��ƾ���
b=repmat(slope',1,N); %abת�ù�ϵ
var_slope=abs(a-b);   %
var_slope(var_slope==0)=100;   %var_slope=0��ζ����ȫ���غ�
var_slope2=unique(var_slope);  %��ȡ��var_slope����Ԫ�����������ȥ���ظ��ģ�

del_index=[];
i=1;
temp=find(var_slope2<0.2);    %find���ص�������ֵ
if ~isempty(temp)  %���temp��Ϊ�գ�~��ȡ��
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

