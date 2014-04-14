 %%read data

close all
clear all
rng('default');
%%
dataPath='/home/li/MVA/Graphcut_shadow/data';
I=imread('/home/li/MVA/Graphcut_shadow/data/toulouse1_qb.gif');
%I=imread('/home/li/MVA/Graphcut_shadow/data/zebra.jpg');
figure,imshow(I);
%% select sub window
window_size=[200,200];
% window_size=[80,80];
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
para.l=10;
shadow=getShadowMask(I_sub,para);


h_out=figure(5),imshow(I_sub),hold on,drawMaskContour(shadow);
%% generate fussy landscape
para_fuzzy.sigma=5;
para_fuzzy.theta=para.theta;
para_fuzzy.l=para.l;

objet=fuzzy(shadow, para_fuzzy);
s1=0.7; % double thresholds
s2=0.9;
objet_seuil=(objet>max(objet(:))*s1 & objet<max(objet(:))*s2);
figure;
imshow(objet_seuil);
figure,drawMask(I_sub,objet_seuil,[1,0,0]);
%% grabcut
user_define=1;
if (user_define)
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
para.beta=10;%gradiant tracking parameter
para.gamma=5;%ising regularity

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



