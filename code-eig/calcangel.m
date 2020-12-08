function [angel,rst,mean_ang] = calcangel(direc)
%% ����direc:ÿ�����ߵķ�������
%% ���angel:ÿ�����ߵĻ���Ƕ�  rst:�������޳���ֵ����м��������������������debug    mean_angel:ƽ������������������ת��
angel = zeros(size(direc,1),size(direc,2));
rst = cell(1,length(direc));
mean_ang = zeros(1,length(direc));
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
    rst{i} = angel_temp;  %�������޳���ֵ����м���
    mean_ang(i) = mean(angel_temp);
end