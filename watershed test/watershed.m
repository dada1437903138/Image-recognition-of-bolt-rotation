clear all;
g=imread('1.jpg');
 %g=rgb2gray(I);
%thresh(g,99,130,150);
%figure(2)     %绘制直方图
[cnts, x] = imhist(g, 256);
[m, n] = size(g);
prob = cnts / m / n;
% sum(prob) == 1
subplot(1,2,1);
plot(x, prob);  title('直方图');
y = medfilt1(prob,6);
subplot(1,2,2);
plot(x,y);title('中值滤波');

b=0;
KK=[ ];
T=0;
temp=100;
for k=2:250
    Kt=0;
    u0=0;
    ub=0;
    sigma0=0;
    sigmab=0;
    ind1=find(g<k);
    ind2=find(g>=k);
% prob0 =zeros(k,1);
     for i=1:k
        prob0(i)=size(find(g==i))/size(ind1);
     end
     for i=1:k
          u0=u0+i*prob0(i);
     end
     for i=1:k
          sigma0=sigma0+prob0(i)*(i-u0)^2;
     end
 
% u0=sum(g(ind1)*prob(g(ind1)));
      for i=k+1:256
          probb(i)=size(find(g==i))/size(ind2);
      end
     for i=k+1:256
           ub=ub+i*probb(i);
     end
     for i=k+1:256
          sigmab=sigmab+probb(i)*(i-ub)^2;
     end

gx=1:1:256;
p0=sum(prob(1:k));
pb=1-p0;

fog0=p0*(exp(-(((gx-u0)/sigma0).^2)/2))/sqrt((2*pi))/sigma0;
fogb=pb*(exp(-(((gx-ub)/sigmab).^2)/2))/sqrt((2*pi))/sigmab;
fog=fog0+fogb;
figure(3)
plot(gx,fog); title('f(g)变化曲线');

pg=p0*fog0+pb*fogb;
pg=pg';
u=unique(g);
u=double(u);
usize=size(u);
  for i=2:usize
        if prob(u(i))~=0
            Kt=Kt+prob(u(i))*log(prob(u(i))/pg(u(i)));
        end
  end
      KK=[KK Kt];  
     if(Kt<temp)
         temp=Kt;
         T=k;
     end
end
figure(4)
plot(KK); title('Kt变化曲线');     %绘制Kt变化曲线
axis([0 256 0 4]);
ind3=find(g>=T);
g(ind3)=255;
ind4=find(g<T);
g(ind4)=0;
figure(5)
imshow(g);title('最优阈值分割结果');

disp('>>输出Kt最小值');
T