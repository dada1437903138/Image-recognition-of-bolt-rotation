function info=polarpeak3(po_sum,t,cen_trans,figname,window,peakdistance_corre)
%% Ѱ�Ҽ��������ݼ�ֵ�������ƽ��
%% po_sumΪ����߽缫�������fignameΪͼƬ���⣬�������ֽڵ��ţ�windowΪ��˹ƽ�����ֵ��peakdistanceΪ��ֵ�ļ��
%%Ϊ��ֹ���ּ�ֵ�ڶ˵���������ǿ��������������
%%peakdistance_correΪ����ֵ
%% ���ص�info�ǲ�÷�ֵ��ļ�����
if nargin < 6
    peakdistance_corre = 40;  %����Ĭ��ֵ
end
if nargin < 5
   window = 12;  %����Ĭ��ֵ
end
f1 = figure('Name',['polar no: ',num2str(figname)]);
f2 = figure('Name',['image no: ',num2str(figname)]); 
for i = 1:length(po_sum)
    
    %�������������ͼ��ƽ����Ѱ�Ҽ���ֵ
    smoth = smoothdata(po_sum{i}(:,1),'gaussian',window);  %��y��ֵ����˹ƽ��
    figure(f1);subplot(2,4,i);h1 = plot(po_sum{i}(:,2),po_sum{i}(:,1),po_sum{i}(:,2),smoth);title(['no:',num2str(i)]);hold on
    peakdistance = length(po_sum{i})/6-peakdistance_corre;  %������
    [maxv,maxl] = findpeaks(smoth,'minpeakdistance',peakdistance,'NPeaks',6,'SortStr','descend'); %maxv���ֵ��  maxl�����ֵ���Ӧ��λ��   ��С���=16 

    %������ģ����Ϊ�˷�ֹ���ֽǵ���0�����360�㸽���޷���ȡ��ֵ�������
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
    
    te2 = po_sum{i}(:,1);  %te,te2��Ϊ��ʱ����
    maxl = sort(maxl);  %�ǶȰ���С��������
    maxv = te2(maxl);  %ǰ���maxv�Ǹ�˹ƽ�����maxֵ���˴�����loc��ϢѰ��ʵ�������϶�Ӧ��ֵ
    te = po_sum{i}(:,2);
    maxl = te([maxl],1);  %���rho��Ӧ�ĽǶ�����
    plot(maxl,maxv,'*','color','R'); legend(h1,'ori','smoothed','location','southeast');hold off   %�������ֵ��  
    info(i).loc = maxl;  %info������˸�����˨�ķ�ֵ��Ϣ
    info(i).val = maxv;
    
    %����˨ͼ�ϻ���Ѱ�ҳ��ļ�ֵ��
    figure(f2);subplot(2,4,i);imshow(t{i});title(['no:',num2str(i)]);hold on
    plot(cen_trans(i,1),cen_trans(i,2),'+','Color','green');text(cen_trans(i,1)+1,cen_trans(i,2)+1,...
         [num2str(round(cen_trans(i,1))),',',num2str(round(cen_trans(i,2)))],'FontSize',10,'Color','yellow'); 
    for k = 1:length(maxv)
        x = cen_trans(i,1)+maxv(k)*cos(maxl(k)/360*2*pi);
        x_sim = round(cen_trans(i,1)+maxv(k)*cos(maxl(k)/360*2*pi));   %x_sim��y_simֻ��Ϊ����ʾ��ֵ�ϵķ���
        y = cen_trans(i,2)-maxv(k)*sin(maxl(k)/360*2*pi);   %ע��ͼ������������
        y_sim = round(cen_trans(i,2)-maxv(k)*sin(maxl(k)/360*2*pi)); 
        plot(x,y,'*','color','R');text(x+1,y+1,[num2str(x_sim),',',num2str(y_sim)],'FontSize',10,'Color','yellow');  %����ֵ������˨ͼ�ϻ��
        axis on;
        %ע�⣺plot�����е�x��y������ͨ��������Ϊ������ϵ��������ͼ������ϵ
    end
end
