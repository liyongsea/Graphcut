%%read data
close all
clear all
%%
I=imread('/home/li/MVA/Graphcut_shadow/data/toulouse1_qb.gif');
size(I);
%%
%select sub window
window_size=[200,200];
window_center=[1400,1400];
I_sub=I(window_center(1)-window_size(1):window_center(1)+window_size(1),window_center(2)-window_size(2):window_center(2)+window_size(2));
figure(),imshow(I_sub);
I_sub=double(I_sub)/255;
%%
figure(),hist(I_sub(:),255);
para=[];
para.method='simple_kmeans';
para.k=5;
shadow=getShadowMask(I_sub,para);

figure(),drawMask(I_sub,shadow,[1,0,0]);