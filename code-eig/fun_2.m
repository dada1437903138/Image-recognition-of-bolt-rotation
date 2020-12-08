function f=fun_2(x,varargin)
%% 图像进行去高光，降噪，锐化
%% x为输入的灰度图，varargin：不输入默认只去高光
f= 2.6136.*(x.^4)-4.034.*(x.^3)+1.1065.*(x.^2)+1.10105.*x -0.0053706;
%f = imadjust(f,[0,0.25],[0,1],0.6); %magnify the contrast
if nargin ==1
    f = f;
elseif nargin ==2
    if varargin{1} ==1  %采用线性平均滤波1
        h = ones(3,3)/5;
        h(1,1)=0; h(1,3)=0; h(3,1)=0; h(1,3)=0;
        f = conv2(f,h);
    end
    if varargin{1} ==2  %采用线性平均滤波2
        h = ones(3,3)/9;
        f = conv2(f,h);
    end
    if varargin{1} ==3  %采用中值滤波
        f = medfilt2(f);
    end
    if varargin{1} ==4  %采用wiener滤波
        f = wiener2(f,[10,10]);
    end
    if varargin{1} ==5  %采用拉普拉斯锐化
        h = [0,1,0;1,-4,1;0,1,0];
        f_lap = conv2(f,h,'same');
        f = f-f_lap;
    end
end



