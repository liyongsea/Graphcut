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
%% multiple chanels images
% dataPath='/home/li/MVA/Graphcut_shadow/data';
% I=imread('/home/li/MVA/Graphcut_shadow/data/im_geoeye_ms.tiff');
% I=I(300:400,:,:);
% I_rgb=double(I(:,:,1:3));
% I_rgb(:,:,1)=double(I(:,:,4));
% I_rgb(I_rgb>400)=400;
% I_rgb=I_rgb./400;
% figure,imshow(I_rgb);
% I_sub=double(I(:,:,1:4));
% I_sub(I_sub>400)=400;
% I_sub=I_sub./400;


%% get shadow from image
figure(),hist(I_sub(:),255);
para=[];
para.method='croissance';
para.k=5;% kmeans centers
para.tolerance=0.2;%growing region threshold
%para.tolerance=5/255;
% para.theta=7*pi/16+pi;%shadow direction toulouse
para.theta=85*pi/180;%shadow direction lille
para.l=5;
shadow=getShadowMask(I_sub,para);
% eliminate small shadow
% se=strel('disk',1);
% shadow=imopen(shadow_first,se);
% sm=zeros(size(shadow));
% sm(55:78,43:100)=1;
% shadow=shadow.*sm;
h_out=figure(5),imshow(I_rgb),hold on,drawMaskContour(shadow);
%% get vegetation mask
figure,imshow(I_rgb)
veg=zeros(size(I_rgb));
veg(:,:,2)=1;
veg_like=I_rgb-veg;
veg_like=exp(-sum(veg_like.*veg_like,3));
veg_mask=double(veg_like>0.5);
se_veg=strel('disk',2);
veg_mask=imclose(veg_mask,se_veg);
figure,subplot(121),imshow(I_rgb),hold on,drawMaskContour(veg_mask),subplot(122),imshow(veg_mask)
%%
shadow=shadow&(~veg_mask);
[L, num] = bwlabel(shadow, 8);
figure,imagesc(L);
%h_out=figure(5),imshow(I_sub),hold on,drawMaskContour(shadow);
para_fuzzy.sigma=5;
para_fuzzy.theta=para.theta;
para_fuzzy.l=para.l;
% get the i connect component in shadow
shadow_clean=zeros(size(I_sub));
for i=0:num
   shadow_i=find(L==i);
   if (shadow(shadow_i(1)))
        A=zeros(size(I_sub));
        A(shadow_i)=1;
        objet=fuzzy(A, para_fuzzy);
        s1=0.6; % double thresholds
        s2=1;
        objet_seuil=(objet>max(objet(:))*s1 & objet<max(objet(:))*s2);
        score=sum(veg_mask(objet_seuil>0.5))/length(shadow_i);
        if (score<0.1)
            shadow_clean(shadow_i)=1;
        end
   end
end
h_out=figure(5),imshow(I_rgb),hold on,drawMaskContour(shadow_clean);
figure,imshow(shadow_clean)
%% genrate building
para_fuzzy.sigma=5;
para_fuzzy.theta=para.theta;
para_fuzzy.l=10;

objet=fuzzy(shadow_clean, para_fuzzy);
s1=0.5; % double thresholds
s2=1;
objet_seuil=(objet>max(objet(:))*s1 & objet<max(objet(:))*s2);
figure;
imshow(objet);
figure,drawMask(I_rgb,shadow,[1 0 0]),hold on,drawMaskContour(objet_seuil&(~veg_mask))%,hold on,drawMaskContour(shadow)

%% generate ROI
para_fuzzy.size=10;
para_fuzzy.theta=para.theta;
para_fuzzy.l=10;

ROI=fuzzy_flat(shadow_clean, para_fuzzy);
figure;
imshow(ROI);
figure,subplot(121),imshow(I_rgb),hold on,drawMaskContour(ROI),subplot(122),imshow(ROI)
%figure,drawMask(I_sub,shadow,[1 0 0]),hold on,drawMaskContour(ROI)%,hold on,drawMaskContour(shadow)
%% grabcut 
% user defines the ROI (no longer needed once the automatisation is implemented)
% user_define=0;
% if (user_define)
%     windows_for=getSubSample(I_rgb,[1 0 0]);
%     save([dataPath '/forground_win.mat'],'windows_for','-ASCII')
% else 
%     windows_for=load([dataPath '/forground_win.mat'],'-ASCII')
% end
% figure(),imshow(I_rgb);hold on
% drawWindows(windows_for,[1,0,0]);

%% assign mask and proceed graph cut
% forgroundMask=zeros(size(I_sub,1),size(I_sub,2));%multi chanel is possible
% forground=[];
% windows_for=floor(windows_for);
% for i=1:size(windows_for,1)
%     forgroundMask(windows_for(i,3):windows_for(i,4),windows_for(i,1):windows_for(i,2))=1;
% end
forgroundMask=(objet_seuil&ROI&(~shadow)&(~veg_mask));
backgroundMask=(~ROI)|(veg_mask);
figure,subplot(131),imshow(I_rgb),subplot(132),imshow(I_rgb),hold on,drawMaskContour(forgroundMask),subplot(133),imshow(double(backgroundMask))
%%
para.max_iteration=5;
para.beta=0.1;%gradiant tracking parameter
para.gamma=4;%ising regularity

[Ireg,evol]=grabcut(I_rgb,forgroundMask,backgroundMask,para);
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



