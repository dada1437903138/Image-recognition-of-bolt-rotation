function bimg=edgsubtract(g,m,n)
%% ��ʾ�߽���ȡЧ��
%% g����ȡ�ı߽��������꣬m��n����ֵͼ��ߴ�
bim = cell(1,length(g));
for i = 1:length(g)                  
    xmin=min(g{i}(:,1));                       
    ymin=min(g{i}(:,2));    
    %����һ����ֵͼ��,��СΪm n��xmin,ymin��B4����С��x��y������                   
    bim{1,i}=bound2im(g{i},m,n,xmin,ymin);    %��g(������Ϣ)ת��Ϊ��ֵͼ�棬������ͨ��Ķ�ֵͼ��
end

bimg = zeros(m,n);      %bim{i}Ϊ��i����˨�߽磬��������Ժ������ͬһ��ͼ����ʾ������˨
for k = 1:length(bim) 
    for i = 1:m
        for j = 1:n
            bimg(i,j) = or(bimg(i,j),bim{k}(i,j)); 
        end
    end
end   
