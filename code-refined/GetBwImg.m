function bw=GetBwImg(img,thr,id,selen)
%% 获取二值图像
if id==1 
    img_bw=im2bw(img,thr);  %thr越小黑色元素越少
    img_bw=~img_bw;  %获得反相图片
    se=strel('octagon',selen);  %用于膨胀腐蚀操作，卷积核的形状和大小  
    %膨胀是去除高亮度元素（如白色），增加低亮度元素（如黑色）
    %膨胀是去除低亮度元素（如黑色），增加高亮度元素（如白色）
    %腐蚀膨胀运算主要用于去除噪点，但会损失图片清晰度
    %SE = strel('octagon',r) creates a octagonal structuring element, 
    %where r specifies the distance from the structuring element origin to
    %the sides of the octagon, as measured along the horizontal and vertical axes.
    %r must be a nonnegative multiple of 3.
    img_bw=imclose(img_bw,se);  %进行闭运算（先膨胀后腐蚀）一般经常进行开闭运算
    bw=imfill(img_bw,'holes');  %填充二值图像中的空洞区域
else  
    img_bw=im2bw(img,thr);      %少了图像反相的过程
    se=strel('octagon',selen);
    img_bw=imclose(img_bw,se);
    bw=imfill(img_bw,'holes');
end