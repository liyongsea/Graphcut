 %%read data

close all
clear all
rng('default');
%%
dataPath='D:/study/Projet-grab/data';
I=imread('D:/study/Projet-grab/data/toulouse1_qb.gif');
%I=imread('/home/li/MVA/Graphcut_shadow/data/zebra.jpg');
figure,imshow(I);
%% select sub window
% window_size=[200,200];
window_size=[80,80];
window_center=[1350,1350];
% window_center=[750,800];
I_sub=I(window_center(1)-window_size(1):window_center(1)+window_size(1),window_center(2)-window_size(2):window_center(2)+window_size(2));
%I_sub=(I);
%I_sub=imresize(I_sub,0.5);
figure(),imshow(I_sub);
I_sub=double(I_sub)/255;

%% get shadow from image
figure(),hist(I_sub(:),255);
para=[];
para.method='croissance';
para.k=5;% kmeans centers
para.tolerance=0.08;%growing region threshold
%para.tolerance=5/255;
para.theta=7*pi/16+pi;%shadow direction
para.l=12;
shadow=getShadowMask(I_sub,para);

h_out=figure(5),imshow(I_sub),hold on,drawMaskContour(shadow);

%% generate ROI
%para_fuzzy.sigma=20;
para_fuzzy.size=30; % size of ROI
para_fuzzy.theta=para.theta;
para_fuzzy.l=30;

objet=fuzzy_flat(shadow, para_fuzzy);
% figure;
% imshow(objet);
figure,drawMask(I_sub,shadow,[1 0 0]),hold on,drawMaskContour(objet)
% hold on,drawMaskContour(shadow)