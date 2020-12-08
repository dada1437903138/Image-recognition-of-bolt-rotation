%%-------------------------------------------------------------------------------%%
%%�����main�����Լ��������ݽ����˸�˹�˲�����������%%
%%���ýǵ�����߶ηָȡЭ�����������ֵ�ֽ⣬���ÿ���߷���
%%�����һ�汾�����˵�λɸѡ
%%���´�ÿһ��ֱ�ߵ����Ļ���ֱ�ߣ������˽⵽�����Բ�������
%%��Ȱ汾4��ȡ����ÿ����˨��ת�ǣ�����ȥ��һ�����ֵ��ȥ��һ����Сֵ��Ȼ��ƽ�����޳�����3sigma��ֵ
%%�޸�ʱ�䣺2020.6.19����
%%-------------------------------------------------------------------------------%%

clear;close all;clc;
%dbstop if error
img = im2bw(imread('1.jpg'));
g = boundaries(img,8);  %���ص�g�Ǹ�����ͨ��ı߽���������,�������Ԥ����õĶ�ֵͼ��
[m,n]=size(img); %���ֵͼ��Ĵ�С
%% ��ʾ�߽���ȡЧ��
for i = 1:length(g)                  
    xmin=min(g{i}(:,1));                       
    ymin=min(g{i}(:,2));    
    %����һ����ֵͼ��,��СΪm n��xmin,ymin��B4����С��x��y������                   
    bim{i}=bound2im(g{i},m,n,xmin,ymin);    %��g(������Ϣ)ת��Ϊ��ֵͼ�棬������ͨ��Ķ�ֵͼ��
end

bimg = zeros(m,n);      %bim{i}Ϊ��i����˨�߽磬��������Ժ������ͬһ��ͼ����ʾ������˨
for k = 1:length(bim) 
    for i = 1:m
        for j = 1:n
            bimg(i,j) = or(bimg(i,j),bim{k}(i,j)); 
        end
    end
end   

%% ��ȡ������ͨ��߽��������Ϣ
for i = 1:length(g)       %�˴���������ʱû����
    cc(i) =fchcode(g{i},8);
end

[bound,cen]=GetTargetBox_2(img);    %��ʾͼ��͸�����ͨ�������
figure;imshow(bimg);hold on;
for i=1:length(cen)
    plot(cen(i,1),cen(i,2),'+','Color','red');  %ע�⣺plot�����е�x��y������ͨ��������Ϊ������ϵ��������ͼ������ϵ
    text(cen(i,1)+20,cen(i,2)+20,['ID:',num2str(i)],'FontSize',10,'Color','red');
end    
for i=1:length(cc)           %�����������,���о�û����
    plot(cc(i).x0y0(1,2),cc(i).x0y0(1,1),'+','Color','blue');  %ע�⣺cc�е�x��y������ͼ������ϵ������Ҫת��һ��
end   
axis on;hold off;

%% ������ת��
cen_trans = zeros(length(bound),2);  %�õ�������˨ͼƬ����λ������
for i = 1:length(bound)
    cen_trans(i,1) = cen(i,1)-bound(i,1)+10;   %10�ǲü���˨ͼƬʱ��Ԥ���߽�
    cen_trans(i,2) = cen(i,2)-bound(i,2)+10;   %cen_trans��x��y����ͨ����ϵ�ģ�����ͼ������ϵ
end

%figure;
for i = 1:length(bound)
    t{i}=bimg(round(bound(i,2)-10):round(bound(i,2)+bound(i,4)+10),round(bound(i,1)-10):round(bound(i,1)+bound(i,3)+10));%t�Ǹ����ü�����Ƭ����ͼƬ
    [mm,nn]=size(t{i});  %��ȡ������˨��Ƭ�ĳߴ�
    a=1;
    %imshow(t{i});hold on;  %��ͼ��ʾɨ�����
    for x =1:mm   %mm��������nn������,�����x,y��ͼ������ϵ�ģ�������cen_trans������ʱע��ת��
        for y =1:nn
            if t{i}(x,y) ==1  %�����һ��Ϊ1������������
                polar(i).rho(a) = norm([y,x]-cen_trans(i,:));
                if x>=cen_trans(i,2)           %�Ƕȷ��ĸ������㣬���Կ�����ͼ�����껻��Ƚ��ƣ����������ָ��ͨ���ޣ��Ұ�ͼ��������ʾ���˾�����Կ�
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
                a=a+1;   
                %plot(y,x,'o','Color','g');hold on;   %��ͼ��ʾɨ�����
                %pause(0.01);
            end
        end
    end
end

%% ����������õ��ļ��������ݣ�Ϊ��һ����׼��
for i = 1:length(polar)
    po = cat(1,polar(i).rho,polar(i).theta);
    po = sortrows(po',2);
    po = cat(2,po(:,1),po(:,2)*360/(2*pi));
    po_sum{i} = po;
end

%% Ѱ�Ҽ��������ݼ�ֵ�������ƽ��
for i = 1:length(po_sum)
    %�������������ͼ��ƽ����Ѱ�Ҽ���ֵ
    smoth = smoothdata(po_sum{i}(:,1),'gaussian',12);  %��y��ֵ����˹ƽ��
    figure(2);subplot(2,4,i);h1=plot(po_sum{i}(:,2),po_sum{i}(:,1),po_sum{i}(:,2),smoth);title(['no:',num2str(i)]);hold on
    [maxv,maxl] = findpeaks(smoth,'minpeakdistance',16); %maxv���ֵ��  maxl�����ֵ���Ӧ��λ��   ��С���=15 
    te2 = po_sum{i}(:,1);  %te,te2��Ϊ��ʱ����
    maxv = te2(maxl);  %ǰ���maxv�Ǹ�˹ƽ�����maxֵ���˴�����loc��ϢѰ��ʵ�������϶�Ӧ��ֵ
    te = po_sum{i}(:,2);
    maxl = te([maxl],1);  %���rho��Ӧ�ĽǶ�����
    plot(maxl,maxv,'*','color','R'); legend(h1,'ori','smoothed');hold off               %�������ֵ��  
    info(i).loc = maxl;  %info������˸�����˨�ķ�ֵ��Ϣ
    info(i).val = maxv;
    %����˨ͼ�ϻ���Ѱ�ҳ��ļ�ֵ��
    figure(3);subplot(2,4,i);imshow(t{i});title(['no:',num2str(i)]);hold on
    for k = 1:length(maxv)
        x = cen_trans(i,1)+maxv(k)*cos(maxl(k)/360*2*pi);
        x_sim = round(cen_trans(i,1)+maxv(k)*cos(maxl(k)/360*2*pi));   %x_sim��y_simֻ��Ϊ����ʾ��ֵ�ϵķ���
        y = cen_trans(i,2)-maxv(k)*sin(maxl(k)/360*2*pi);   %ע��ͼ������������
        y_sim = round(cen_trans(i,2)-maxv(k)*sin(maxl(k)/360*2*pi)); 
        plot(x,y,'*','color','R');text(x+1,y+1,[num2str(x_sim),',',num2str(y_sim)],'FontSize',10,'Color','yellow');  %����ֵ������˨ͼ�ϻ��
        plot(cen_trans(i,1),cen_trans(i,2),'+','Color','green');text(cen_trans(i,1)+1,cen_trans(i,2)+1,...
            [num2str(round(cen_trans(i,1))),',',num2str(round(cen_trans(i,2)))],'FontSize',10,'Color','yellow'); 
        axis on;
        %ע�⣺plot�����е�x��y������ͨ��������Ϊ������ϵ��������ͼ������ϵ
    end
end

%% ���ݼ����꼫ֵ���и�����Ե�ֶ�,�ڿ����Ͻ��зֶκ����׳�������
for i = 1:length(po_sum)  %����������˨
    for j = 1:length(info(i).loc) %����������ֵ��,˳��Ϊ1-2��2-3��3-4��4-5��5-6��6-1
        if j <= length(info(i).loc)-1
            ind = find(po_sum{i}(:,2)>=info(i).loc(j) & po_sum{i}(:,2)<info(i).loc(j+1));  %����������ֵ����������ص������
            temp = po_sum{i}(:,1); %�м����
            temp2 = po_sum{i}(:,2);
            po_line{i,j}(:,1) = temp(ind);  %������Щ�м���tho
            po_line{i,j}(:,2) = temp2(ind); %������Щ�м���theta
        elseif j == length(info(i).loc) %�����������һ���ߵ�ʱ��
            ind = find(po_sum{i}(:,2)>=info(i).loc(j) | po_sum{i}(:,2)<info(i).loc(1));  %���ش���6С��1֮����������ص������
            temp = po_sum{i}(:,1); %�м����
            temp2 = po_sum{i}(:,2);
            po_line{i,j}(:,1) = temp(ind);  %������Щ�м���tho       ����������˨������������ȡ���ĸ�����
            po_line{i,j}(:,2) = temp2(ind);  %������Щ�м���theta
        end
    end
end

%% ����ȡ���ĸ����߶�ת��Ϊ�ѿ�������ϵ
% �õ���line�е�����Ϊͨ�����꣬ͼ������ϵ��x��yҪ����
[m,n] = size(po_line);
for i = 1:m
    for j = 1:n
        line{i,j}(:,1) = cen_trans(i,1)+po_line{i,j}(:,1).*cos(po_line{i,j}(:,2)/360*2*pi);  %���м�ĳ˷�ע���õ��
        line{i,j}(:,2) = cen_trans(i,2)-po_line{i,j}(:,1).*sin(po_line{i,j}(:,2)/360*2*pi);   %ע��ͼ������������
    end
end


%��������ֵ�ֽ���ֱ�߷�������������ʾ��ȡЧ��
figure;
for i = 1:length(t)
    [m,n] = size(t{i});
    tesimg{i} = zeros(m,n);  %������ÿ��ͼƬ�Ŀվ���
    
    for j = 1:size(line,2)
        pos = round(line{i,j});  %��ͼ������ת��Ϊ�������������
        tesimg{i}(sub2ind(size(t{i}),pos(:,2),pos(:,1)))=1;  %ע��pos�����ͨ������ϵ��ת��Ϊͼ��ʱx��yҪ����  sub2ind�ܺ���
    end
    
    subplot(2,4,i);imshow(tesimg{i});axis on;title(['no:',num2str(i)]);hold on;  %�Ȼ�����˨
    
    for j = 1:size(line,2)
           line{i,j} = sortrows(line{i,j},[2,1],'descend');  %���ȸ���y�����ɴ�С��˳��Ȼ�����x���꣬�����е���������
           %ȥ�����------------------------------------------
           covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
           [V,D] = eig(covariance);
           std_line = line{i,j}-mean(line{i,j});  %Ϊ��������ͶӰ��׼��
           st = 3*sqrt(D(1,1));  %d2�����ž�����������ϵı�׼��޳�����3sigma�ĵ�
           clear cast;
           for k =1:length(std_line)
               cast(k)=std_line(k,:)*V(:,1); %����ÿ�����ڷ������ϵ�ͶӰ
           end
           cast = cast';
           ind = find(abs(cast)>st); %�ҳ�ͶӰ�д���3sigma�ĵ�
           line{i,j}(ind,:) = [];  %ȥ��ͶӰ�д���3sigma�ĵ�
           %--------------------------------------------------
           covariance = cov(line{i,j}(:,1),line{i,j}(:,2));
           [V,D] = eig(covariance);  %���¼���Э�������������ֵ�ֽ�
           direc{i,j} = V(:,2); %���淽��������Ϊ����Ƕ���׼��
           temp = mean(line{i,j});
           plot(temp(1,1),temp(1,2),'*','Color','green'); %������߶�����
           %dis = sqrt(D(2,2)); %���㻭�ߵĳ��ȣ�������ֵ������
           dis = 12; %��㶨��һ��ֵ���������ÿ�һ��
           x1 = temp(1,1)+V(1,2)*ceil(dis);  %�����ĺͷ��������������ֱ�߶˵�����
           y1 = temp(1,2)+V(2,2)*ceil(dis);
           x2 = temp(1,1)-V(1,2)*ceil(dis);
           y2 = temp(1,2)-V(2,2)*ceil(dis);
           plot(x1,y1,'o','Color','yellow'); %���Ƴ�eig�ֽ�����߶�������������߶ζ˵�
           plot(x2,y2,'o','Color','yellow'); %���Ƴ�eig�ֽ�����߶�������������߶ζ˵�
           plot([x1,x2],[y1,y2],'LineWidth',2,'Color','red');
           %���Ƴ��ɽǵ㶨��ֱ�ߣ����бȽ�
           x_cor = [line{i,j}(1,1),line{i,j}(length(line{i,j}),1)];  
           y_cor = [line{i,j}(1,2),line{i,j}(length(line{i,j}),2)];
           plot(x_cor,y_cor,'LineWidth',1,'Color','blue');     
    end
end
           
%��ȡ��˨ƽ��ת��
for i = 1:length(direc)
    for j = 1:length(direc(i,:))
        temp = direc{i,j};
        if temp(1,1) >= 0  %�������޼���Ƕȣ���x����y����ת����Ϊ��������ʾ���ipad����ͼ
            if temp(2,1) >= 0  %��������ͼ������ϵ��һ����
                angel(i,j) = acos(temp(1,1)/norm(temp))*360/2/pi;  %d=(x,y),����x������ļн�����ֵ��cosa=x/sqrt(x^2+y^2)
            elseif temp(2,1) < 0  %��������ͼ������ϵ��������
                angel(i,j) = (2*pi-acos(temp(1,1)/norm(temp)))*360/2/pi;
            end
        elseif temp(1,1) < 0
            if temp(2,1) >= 0  %��������ͼ������ϵ�ڶ�����
                angel(i,j) = (pi-acos(abs(temp(1,1))/norm(temp)))*360/2/pi;
            elseif temp(2,1) < 0  %��������ͼ������ϵ��������
                angel(i,j) = (pi+acos(abs(temp(1,1))/norm(temp)))*360/2/pi;
            end 
        end
        angel(i,j) = rem(angel(i,j),60);
    end
    %ÿ��ֱ�ߵĽǶ��޳�һ�����ֵ���޳�һ����Сֵ
    angel_temp = sort(angel(i,:),'descend'); 
    angel_temp(1) = [];
    angel_temp(length(angel_temp)) = [];  %�޳������Сֵ
    sd = std(angel_temp);   %��Ϊֻ����ȡ��Լ6���Ƕȣ�����С��������̬�ֲ��޳�3sigmaֵ�ķ�����������
    me = mean(angel_temp);
    ind = find(angel(i,:)<me-3*sd|angel(i,:)>me+3*sd);
    angel_temp = angel(i,:);
    angel_temp(ind) = [];
    res{i} = angel_temp;
    mean_ang(i) = mean(angel_temp);
end




    