function direc = eigdecompose3(line,t,figname,dis)
%% ��������ֵ�ֽ���ֱ�߷���������������ʾ��ȡЧ����������
%% ����line:ÿ�����ߵĵѿ�������   t:�����ָ����ÿ����˨ͼƬ  figname:ͼƬ���ƣ��ڼ��Žڵ���ͼƬ   dis��ͼƬ�ϻ��Ƶ��ߵĳ���
%% ���direc:ÿ�����ߵķ�������
if nargin < 4
    dis = 35;
    %dis = sqrt(D(2,2)); %���㻭�ߵĳ��ȣ�������ֵ������
end
tesimg = cell(1,length(t));
direc = cell(length(t),size(line,2));
for i = 1:length(t)
    [m,n] = size(t{i});
    figure;
    tesimg{i} = zeros(m,n);  %������ÿ��ͼƬ�Ŀվ���
    for j = 1:size(line,2)
        if ~isempty(line{i,j})
            pos = round(line{i,j});  %��ͼ������ת��Ϊ�������������
            tesimg{i}(sub2ind(size(t{i}),pos(:,2),pos(:,1)))=1;  %ע��pos�����ͨ������ϵ��ת��Ϊͼ��ʱx��yҪ����  sub2ind�ܺ���
        end  
    end
    
    imshow(tesimg{i});
    %axis on;
    title(['no:',num2str(i)]);hold on;  %�Ȼ�����˨
    
    for j = 1:size(line,2)
        if ~isempty(line{i,j})
            line{i,j} = sortrows(line{i,j},[2,1],'descend');  %���ȸ���y�����ɴ�С��˳��Ȼ�����x���꣬�����е���������
            %ȥ�����------------------------------------------
            covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
            [V,D] = eig(covariance);
            std_line = line{i,j}-mean(line{i,j});  %Ϊ��������ͶӰ��׼��
            st = 3*sqrt(D(1,1));  %d2�����ž�����������ϵı�׼��޳�����3sigma�ĵ�
            cast = zeros(length(std_line),1);
            for k =1:length(std_line)
                cast(k)=std_line(k,:)*V(:,1); %����ÿ�����ڷ������ϵ�ͶӰ
            end
            cast = cast';
            ind = find(abs(cast)>st); %�ҳ�ͶӰ�д���3sigma�ĵ�
            line{i,j}(ind,:) = [];  %ȥ��ͶӰ�д���3sigma�ĵ�
            %--------------------------------------------------
            covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
            [V,D] = eig(covariance);  %���¼���Э�������������ֵ�ֽ�,һ��ϴ������ֵ�ڵڶ���
            direc{i,j} = V(:,2); %���淽��������Ϊ����Ƕ���׼��
            temp = mean(line{i,j});
            %plot(temp(1,1),temp(1,2),'*','Color','green'); %������߶�����
            x1 = temp(1,1)+V(1,2)*ceil(dis);  %�����ĺͷ��������������ֱ�߶˵�����
            y1 = temp(1,2)+V(2,2)*ceil(dis);
            x2 = temp(1,1)-V(1,2)*ceil(dis);
            y2 = temp(1,2)-V(2,2)*ceil(dis);
            plot(x1,y1,'o','Color','yellow','LineWidth',2); %���Ƴ�eig�ֽ�����߶�������������߶ζ˵�
            plot(x2,y2,'o','Color','yellow','LineWidth',2); %���Ƴ�eig�ֽ�����߶�������������߶ζ˵�
            plot([x1,x2],[y1,y2],'LineWidth',3,'Color','red');
%             %���Ƴ��ɽǵ㶨��ֱ�ߣ����бȽ�
%             x_cor = [line{i,j}(1,1),line{i,j}(length(line{i,j}),1)];  
%             y_cor = [line{i,j}(1,2),line{i,j}(length(line{i,j}),2)];
%             plot(x_cor,y_cor,'LineWidth',1,'Color','blue');   
        end 
    end
    %% ����hough��ȡ������Ϊ�Ա�
    xy1=GetLines_2(t{i},40,10);  %��ȡ����任
    for j=1:length(xy1)
        points = [xy1(j).point1; xy1(j).point2];
        plot(points(:,1),points(:,2),'LineWidth',2,'Color','yellow');
        %plot(points(1,1),points(1,2),'x','LineWidth',1,'Color','yellow');
        %plot(points(2,1),points(2,2),'x','LineWidth',1,'Color','red');
    end
    %======================================================================
end