function [po_sum,t,cen_trans] = car2pol(bimg,cen,bound)
%% ����˨�����ϸ������ص�Ŀռ�����ת��Ϊ������
%% �����������ʸ����ȡ���Ķ�ֵ��Եͼ����ͨ�����ġ�����
%%������Ǹ����������ߵ�theta-rho����,�Լ��ü����ĵ���ͼƬ,��������
cen_trans = zeros(length(bound),2);  %�õ�������˨ͼƬ����λ������
%����������ü�ͼƬ����������
for i = 1:length(bound)
    cen_trans(i,1) = cen(i,1)-bound(i,1)+10;   %10�ǲü���˨ͼƬʱ��Ԥ���߽�
    cen_trans(i,2) = cen(i,2)-bound(i,2)+10;   %cen_trans��x��y����ͨ����ϵ�ģ�����ͼ������ϵ
end
%figure;
t = cell(1,length(bound)); %Ԥ�����ڴ�
for i = 1:length(bound)
    t{i}=bimg(round(bound(i,2)-10):round(bound(i,2)+bound(i,4)+10),round(bound(i,1)-10):round(bound(i,1)+bound(i,3)+10));%t�Ǹ����ü�����Ƭ����ͼƬ
    [m,n]=size(t{i});  %��ȡ������˨��Ƭ�ĳߴ�
    a=1;
%   polar = struct('rho',{},'theta',{}); %Ԥ�����ڴ�,����rho��theta��ֵ��Ȼδ֪
%   polar = repmat(polar,1,length(bound)); %��Ȼ��̫��Ϊ�ṹ��Ԥ�����ڴ�
    %imshow(t{i});hold on;  %��ͼ��ʾɨ�����
    for x =1:m   %mm��������nn������,�����x,y��ͼ������ϵ�ģ�������cen_trans������ʱע��ת��
        for y =1:n
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

%% ����������õ��ļ��������ݣ����ǶȰ�0-360�����У�Ϊ��һ����׼��
po_sum = cell(1,length(polar));
for i = 1:length(polar)
    po = cat(1,polar(i).rho,polar(i).theta);
    po = sortrows(po',2);
    po = cat(2,po(:,1),po(:,2)*360/(2*pi));
    po_sum{i} = po;
end