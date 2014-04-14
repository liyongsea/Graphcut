close all;
clear all;
dataPath='D:/study/Graphcut-master/data';
I=imread('D:/study/Graphcut-master/data/Synthetique/batiment_ombre.png');
% I=imread('D:/study/Graphcut-master/data/Synthetique/carre.png');

I=rgb2gray(I);
% I=I(1:440,1:440);
I=double(I)./255;

figure,imshow(I);

m1=0.8;
m2=0.4;
sigma1=.1;
sigma2=.1;
%%
foreground=(I>0.2).*(I<0.8);
background=(I>0.9);
mask=(I<0.2).*I;

% foreground=(I>0.2).*(I<0.4);
% background=(I>0.8);
% mask=(I<0.2).*I;
figure,imshow(foreground);
figure, imshow(background);


%%
mask=mask+addGaussian(m1,sigma1,foreground)+addGaussian(m2,sigma2,background);

mask(mask>1)=1;
mask(mask<0)=0;
h=figure,imshow(mask);

figure;
hist(mask(:),255);
I_sub=mask;
%% grabcut
user_define=1;
if (user_define)
    figure(h),
    windows_for=getSubSample(I_sub,[1 0 0]);
    save([dataPath '/forground_win.mat'],'windows_for','-ASCII')
else 
    windows_for=load([dataPath '/forground_win.mat'],'-ASCII')
end
figure(),imshow(I_sub);hold on
drawWindows(windows_for,[1,0,0]);
%% assign mask and proceed graph cut
forgroundMask=zeros(size(I_sub,1),size(I_sub,2));%multi chanel is possible
forground=[];
windows_for=floor(windows_for);
for i=1:size(windows_for,1)
    forgroundMask(windows_for(i,3):windows_for(i,4),windows_for(i,1):windows_for(i,2))=1;
end
para.max_iteration=7;
para.beta=10;
para.gamma=5;

[Ireg,evol]=grabcut(I_sub,forgroundMask,para);
%% plot
figure(),subplot(121),imshow(I_sub);subplot(122),imshow(Ireg);

h=figure(),drawMask(I_sub,Ireg,[1,0,0]);
saveas(h,'example','pdf')
%%
figure, subplot(2,3,1),imshow(I_sub);
for i=1:5
   subplot(2,3,i+1), imshow(evol(:,:,i))
end


