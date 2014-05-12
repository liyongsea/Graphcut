 %%read data

close all
clear all
rng('default');
%%
dataPath='/home/li/MVA/Graphcut_shadow/data';
% I=imread('/home/li/MVA/Graphcut_shadow/data/lille.jpg');
I=imread('/home/li/MVA/Graphcut_shadow/data/toulouse1_qb.gif');
%I=imread('/home/li/MVA/Graphcut_shadow/data/zebra.jpg');
figure,imshow(I);
%% select sub window
% window_size=[200,200];
window_size=[100,100];%toulouse
% window_size=[60,60];%lille
window_center=[1350,1350]; %toulouse
% window_center=[430, 430]; %lille
% window_center=[600, 700]; %lille
% window_center=[750,800];
I_sub=I(window_center(1)-window_size(1):window_center(1)+window_size(1),window_center(2)-window_size(2):window_center(2)+window_size(2),:);
%I_sub=(I);
%I_sub=imresize(I_sub,0.5);

I_sub=double(I_sub)/255;
if (size(I_sub,3)==1)
    I_rgb=repmat(I_sub,[1,1,3]);
else
    I_rgb=I_sub;
    I_sub=rgb2gray(I_rgb);
end
figure(),imshow(I_rgb);
%%
windows_for=getSubSample(I_rgb,[1 0 0]);
hf=figure(),imshow(I_rgb);hold on
drawWindows(windows_for,[1,0,0]);
set(gca,'position',[0 0 1 1],'units','normalized')
saveas(hf,'init','png');
%%
forgroundMask=zeros(size(I_sub,1),size(I_sub,2));%multi chanel is possible
forground=[];
windows_for=floor(windows_for);
for i=1:size(windows_for,1)
    forgroundMask(windows_for(i,3):windows_for(i,4),windows_for(i,1):windows_for(i,2))=1;
end
%%
forground=extractFromMask(I_sub,forgroundMask);
hf=figure,[h1,c1]=hist(forground,100)
hold on,plot(c1,h1./trapz(c1,h1),'-b','LineWidth',2)
x=[0:0.005:1]';
for_mixture=GaussianMixture(forground,3);
drawGaussianMixture(for_mixture,x);
% set(gca,'position',[0 0 1 1],'units','normalized')
saveas(hf,'fore_hist','png');
%%
background=extractFromMask(I_sub,~forgroundMask);
hf=figure,[h1,c1]=hist(background,80)
hold on,plot(c1,h1./trapz(c1,h1),'-b','LineWidth',2)
x=[0:0.005:1]';
back_mixture=GaussianMixture(background,3);
drawGaussianMixture(back_mixture,x);
% set(gca,'position',[0 0 1 1],'units','normalized')
saveas(hf,'back_hist','png');
%%
para.max_iteration=5;
para.beta=0.1;%gradiant tracking parameter
para.gamma=6;%ising regularity

[Ireg,evol]=grabcut(I_sub,forgroundMask,[],para);
%% plot
figure(),subplot(121),imshow(I_rgb);subplot(122),imshow(Ireg);

h=figure(),%drawMask(I_rgb,Ireg,[1,0,0]);
imshow(I_rgb)
hold on,drawMaskContour(Ireg)
saveas(h,'example','pdf')
%%
figure, subplot(2,3,1),imshow(I_rgb);
for i=1:5
   subplot(2,3,i+1), imshow(evol(:,:,i))
end
%%
for i=1:5
h=figure(),%drawMask(I_rgb,Ireg,[1,0,0]);
imshow(I_rgb)
hold on,drawMaskContour(evol(:,:,i))
set(gca,'position',[0 0 1 1],'units','normalized')
saveas(h,['result_' num2str(i)],'png')
end