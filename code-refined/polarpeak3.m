function info=polarpeak3(po_sum,t,cen_trans,figname,window,peakdistance_corre)
%% 寻找极坐标数据极值，并绘制结果
%% po_sum为输入边界极坐标矩阵，figname为图片标题，用于区分节点板号，window为高斯平滑宽度值，peakdistance为求极值的间隔
%%为防止出现极值在端点的情况，加强代码改善这个问题
%%peakdistance_corre为修正值
%% 返回的info是测得峰值点的极坐标
if nargin < 6
    peakdistance_corre = 40;  %设置默认值
end
if nargin < 5
   window = 12;  %设置默认值
end
f1 = figure('Name',['polar no: ',num2str(figname)]);
f2 = figure('Name',['image no: ',num2str(figname)]); 
for i = 1:length(po_sum)
    
    %汇出极坐标曲线图，平滑并寻找极大值
    smoth = smoothdata(po_sum{i}(:,1),'gaussian',window);  %对y轴值做高斯平滑
    figure(f1);subplot(2,4,i);h1 = plot(po_sum{i}(:,2),po_sum{i}(:,1),po_sum{i}(:,2),smoth);title(['no:',num2str(i)]);hold on
    peakdistance = length(po_sum{i})/6-peakdistance_corre;  %测试用
    [maxv,maxl] = findpeaks(smoth,'minpeakdistance',peakdistance,'NPeaks',6,'SortStr','descend'); %maxv峰峰值点  maxl：峰峰值点对应的位置   最小间隔=16 

    %新增该模块是为了防止出现角点在0°或者360°附近无法提取极值点的问题
    if length(maxl) < 6
        if po_sum{i}(1,1) >= po_sum{i}(end,1)
            maxl = cat(1,maxl,1);
            %maxv = cat(1,maxv,po_sum{i}(1,1));
        else
            maxl = cat(1,maxl,length(po_sum{i}));
            %maxv = cat(1,maxv,po_sum{i}(end,1));
        end
    end
    %================================================================
    
    te2 = po_sum{i}(:,1);  %te,te2均为临时变量
    maxl = sort(maxl);  %角度按从小到大排列
    maxv = te2(maxl);  %前面的maxv是高斯平滑后的max值，此处利用loc信息寻找实际曲线上对应的值
    te = po_sum{i}(:,2);
    maxl = te([maxl],1);  %最大rho对应的角度坐标
    plot(maxl,maxv,'*','color','R'); legend(h1,'ori','smoothed','location','southeast');hold off   %绘制最大值点  
    info(i).loc = maxl;  %info里包含了各个螺栓的峰值信息
    info(i).val = maxv;
    
    %在螺栓图上绘制寻找出的极值点
    figure(f2);subplot(2,4,i);imshow(t{i});title(['no:',num2str(i)]);hold on
    plot(cen_trans(i,1),cen_trans(i,2),'+','Color','green');text(cen_trans(i,1)+1,cen_trans(i,2)+1,...
         [num2str(round(cen_trans(i,1))),',',num2str(round(cen_trans(i,2)))],'FontSize',10,'Color','yellow'); 
    for k = 1:length(maxv)
        x = cen_trans(i,1)+maxv(k)*cos(maxl(k)/360*2*pi);
        x_sim = round(cen_trans(i,1)+maxv(k)*cos(maxl(k)/360*2*pi));   %x_sim和y_sim只是为了显示数值上的方便
        y = cen_trans(i,2)-maxv(k)*sin(maxl(k)/360*2*pi);   %注意图像坐标轴正负
        y_sim = round(cen_trans(i,2)-maxv(k)*sin(maxl(k)/360*2*pi)); 
        plot(x,y,'*','color','R');text(x+1,y+1,[num2str(x_sim),',',num2str(y_sim)],'FontSize',10,'Color','yellow');  %将极值点在螺栓图上绘出
        axis on;
        %注意：plot命令中的x，y坐标是通常人们认为的坐标系，而不是图像坐标系
    end
end
