function [bound,cen]=GetTargetBox_2(img_bw)
%% �ú�����Ҫ���ݲ�ͬ�Ų�����˨��ʽ�����޸�
[L, ~] = bwlabel(img_bw);%�Զ�ֵͼ���б��  Ĭ�ϵ�Ϊ8��ͨ����ң�LΪ���ص���ͨ��ͼ��
%figure;imagesc(L)   %imagesc��colormap�й�
%�Զ�ֵͼ�еĸ�����ͨ�����������ȡ
stats=regionprops(L,'Area','Centroid','BoundingBox');  %��������ͼ���������Եĺ�����ʹ��ǰҪ��bwlabel
%'Area'�Ǳ������������ͼ����������������ܸ�����
%'Centroid'��1��ndims(L)�е�����������ÿ����������ģ����ģ���
%ע�⣺Centroid �ĵ�һ��Ԫ��������ˮƽ���꣨x���꣩���ڶ���Ԫ�������Ĵ�ֱ���꣨y���꣩
%'BoundingBox' ��1��ndims(L)*2�е�����,��������Ӧ�������С���� �����������Ͻ�����ͳ���
cen = cat(1,stats.Centroid);%��ͨ����������  cat(1,...)������������  cen��Ϊ������ͨ�����������
BoundingBox = cat(1, stats.BoundingBox);%��ӱ߿�    ����cat��ȡ������
%% �����ݰ������к��е�˳�������Է���������ñ�Ķ�Ӧ
% bound=sortrows(BoundingBox,[1,2]);  %�����갴�մ����ҡ����ϵ��µ�˳�������������֤����Ч������Ҫ�ֶ�����
% cen=sortrows(cen,[1,2]);

%%ע�⣬bound��cen�ֿ�����Ļ����п��ܳ��ִ���

cenl=sortrows(cen(1:4,:),2);
cenr=sortrows(cen(5:end,:),2);
cen=[cenl;cenr];
bl=sortrows(BoundingBox(1:4,:),2);      %sortrow������y�����˳����ȡ       %%��������˨�Ų���ͬ���ı�
br=sortrows(BoundingBox(5:end,:),2);    %������������˨Ⱥ���������ͳ��������
bound=[bl;br];