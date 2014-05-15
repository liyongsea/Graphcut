 %%read data

close all
clear all
rng('default');
%%
dataPath='/home/li/MVA/Graphcut_shadow/data/vatican';
I=imread('/home/li/MVA/Graphcut_shadow/data/vatican/van.jpg');
% I=imread('/home/li/MVA/Graphcut_shadow/data/toulouse1_qb.gif');
%I=imread('/home/li/MVA/Graphcut_shadow/data/zebra.jpg');
figure,imshow(I);
%% select sub window
% window_size=[200,200];
window_size=[250,250];%toulouse
% window_size=[60,60];%lille
% window_center=[1350,1350]; %toulouse
% window_center=[430, 430]; %lille
window_center=[600, 700]; %lille
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
imwrite(I_rgb,[dataPath,'/Image'],'jpg');
%%
% windows_for=load([dataPath '/../veg_win.mat'],'-ASCII')
windows_for=getSubSample(I_rgb,[1 0 0]);
% save([dataPath '/veg_win.mat'],'windows_for','-ASCII')
%%

figure(),imshow(I_rgb);hold on
drawWindows(windows_for,[1,0,0]);
%%
vegMask=zeros(size(I_sub,1),size(I_sub,2));%multi chanel is possible
forground=[];
windows_for=floor(windows_for);
for i=1:size(windows_for,1)
    vegMask(windows_for(i,3):windows_for(i,4),windows_for(i,1):windows_for(i,2))=1;
end
%%
veg=extractFromMask(I_rgb,vegMask);
%%
para.max_iteration=5;
para.beta=0.1;%gradiant tracking parameter
para.gamma=3;%ising regularity

[Ireg,evol]=grabcut(I_rgb,vegMask,[],para);
%% plot
figure(),subplot(121),imshow(I_rgb);subplot(122),imshow(Ireg);

h=figure(),%drawMask(I_rgb,Ireg,[1,0,0]);
imshow(I_rgb)
hold on,drawMask(I_rgb,Ireg,[0 1 0])
%%
save([dataPath '/veg_mask.mat'],'Ireg','-ASCII')
