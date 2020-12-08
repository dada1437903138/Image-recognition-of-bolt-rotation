function direc = eigdecompose3(line,t,figname,dis)
%% 进行特征值分解求直线方向向量，单独显示提取效果，论文用
%% 输入line:每条边线的笛卡尔坐标   t:独立分割出的每个螺栓图片  figname:图片名称，第几张节点板的图片   dis：图片上绘制的线的长度
%% 输出direc:每个边线的方向向量
if nargin < 4
    dis = 35;
    %dis = sqrt(D(2,2)); %计算画线的长度，即特征值开根号
end
tesimg = cell(1,length(t));
direc = cell(length(t),size(line,2));
for i = 1:length(t)
    [m,n] = size(t{i});
    figure;
    tesimg{i} = zeros(m,n);  %创建出每个图片的空矩阵
    for j = 1:size(line,2)
        if ~isempty(line{i,j})
            pos = round(line{i,j});  %将图像坐标转换为像素坐标的整数
            tesimg{i}(sub2ind(size(t{i}),pos(:,2),pos(:,1)))=1;  %注意pos里的是通用坐标系，转换为图像时x，y要调换  sub2ind很好用
        end  
    end
    
    imshow(tesimg{i});
    %axis on;
    title(['no:',num2str(i)]);hold on;  %先画出螺栓
    
    for j = 1:size(line,2)
        if ~isempty(line{i,j})
            line{i,j} = sortrows(line{i,j},[2,1],'descend');  %首先根据y坐标由大到小的顺序，然后根据x坐标，对所有点重新排序
            %去除误差------------------------------------------
            covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
            [V,D] = eig(covariance);
            std_line = line{i,j}-mean(line{i,j});  %为后来计算投影做准备
            st = 3*sqrt(D(1,1));  %d2开根号就是这个方向上的标准差，剔除超过3sigma的点
            cast = zeros(length(std_line),1);
            for k =1:length(std_line)
                cast(k)=std_line(k,:)*V(:,1); %计算每个点在法向量上的投影
            end
            cast = cast';
            ind = find(abs(cast)>st); %找出投影中大于3sigma的点
            line{i,j}(ind,:) = [];  %去除投影中大于3sigma的点
            %--------------------------------------------------
            covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
            [V,D] = eig(covariance);  %重新计算协方差，并进行特征值分解,一般较大的特征值在第二列
            direc{i,j} = V(:,2); %储存方向向量，为计算角度做准备
            temp = mean(line{i,j});
            %plot(temp(1,1),temp(1,2),'*','Color','green'); %绘出各线段质心
            x1 = temp(1,1)+V(1,2)*ceil(dis);  %从质心和方向向量推算出的直线端点坐标
            y1 = temp(1,2)+V(2,2)*ceil(dis);
            x2 = temp(1,1)-V(1,2)*ceil(dis);
            y2 = temp(1,2)-V(2,2)*ceil(dis);
            plot(x1,y1,'o','Color','yellow','LineWidth',2); %绘制出eig分解后由线段质心推算出的线段端点
            plot(x2,y2,'o','Color','yellow','LineWidth',2); %绘制出eig分解后由线段质心推算出的线段端点
            plot([x1,x2],[y1,y2],'LineWidth',3,'Color','red');
%             %绘制出由角点定的直线，进行比较
%             x_cor = [line{i,j}(1,1),line{i,j}(length(line{i,j}),1)];  
%             y_cor = [line{i,j}(1,2),line{i,j}(length(line{i,j}),2)];
%             plot(x_cor,y_cor,'LineWidth',1,'Color','blue');   
        end 
    end
    %% 绘制hough提取的线作为对比
    xy1=GetLines_2(t{i},40,10);  %提取霍夫变换
    for j=1:length(xy1)
        points = [xy1(j).point1; xy1(j).point2];
        plot(points(:,1),points(:,2),'LineWidth',2,'Color','yellow');
        %plot(points(1,1),points(1,2),'x','LineWidth',1,'Color','yellow');
        %plot(points(2,1),points(2,2),'x','LineWidth',1,'Color','red');
    end
    %======================================================================
end