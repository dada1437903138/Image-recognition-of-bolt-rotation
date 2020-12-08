function line = segment2car(po_sum,info,cen_trans)
%% ���ݼ����꼫ֵ���и�����Ե�ֶ�,�ڿ����Ͻ��зֶκ����׳�������
%% ����po_sumΪһ����ͼ�и�����ͨ����������������У�infoΪ���������ǵ㼫����
%% ���ص�line��Ϊ���ݽǵ�ֶκ�ĸ��߶εѿ�������ϵ
po_line = cell(length(po_sum),length(info(1).loc));  %����Ԥ�����ڴ��ʱ��length(info(i).loc)��Ӧ������i��ͬ����ͬ���������ﶼ����ȡ�����ߵģ����Ծ�ͼʡ����
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
line = cell(m,n);
for i = 1:m
    for j = 1:n
        if ~isempty(po_line{i,j})  %��ֹ���ַ�ֵ����ȡ�������±�������6��
            line{i,j}(:,1) = cen_trans(i,1)+po_line{i,j}(:,1).*cos(po_line{i,j}(:,2)/360*2*pi);  %���м�ĳ˷�ע���õ��
            line{i,j}(:,2) = cen_trans(i,2)-po_line{i,j}(:,1).*sin(po_line{i,j}(:,2)/360*2*pi);   %ע��ͼ������������
        end
    end
end