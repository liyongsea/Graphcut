% this script illustre a automatic building segmentation method proposed by
% Ok et al. 2014, based on grab cut. In order to run the script, please
% prepare a data directory containing a multi chanel image to be segmented
% ('Image'), and a vegetation mask (veg_mask.mat, can be generated using vegetation_learning.m if Image is optic)

close all
clear all
rng('default');
%% read image
dataPath='/home/li/MVA/Graphcut_shadow/data/lille/';
I=imread([dataPath '/Image']);
I=double(I)./255;
% I=imread('/home/li/MVA/Graphcut_shadow/data/toulouse1_qb.gif');
% I=imread('/home/li/MVA/Graphcut_shadow/data/zebra.jpg');
hf=figure,imshow(I);
set(gca,'position',[0 0 1 1],'units','normalized')
% saveas(hf,[dataPath],'png');
%% read vegetation mask
veg_mask= load([dataPath 'veg_mask.mat'],'-ASCII');
hold on, drawMaskContour(veg_mask);title('vegetation mask');

%% compute the shadow mask on image
I_gray=rgb2gray(I);
para.method='croissance';
para.k=6;% kmeans centers
para.tolerance=0.2;%growing region threshold

para.theta=75*pi/180; %shadow direction lille
para.l=5; %the minimum length of a shadow to keep
shadow=getShadowMask(I_gray,para);
figure, drawMask(I,shadow,[1 0 0]);

%% clean the shadow by eliminating the vegetation

[L, num] = bwlabel(shadow, 8);
figure,imagesc(L);
%h_out=figure(5),imshow(I_sub),hold on,drawMaskContour(shadow);
para_fuzzy.sigma=5;
para_fuzzy.theta=para.theta;
para_fuzzy.l=para.l;
% get the i connect component in shadow
shadow_clean=zeros(size(I_gray));
for i=0:num
   shadow_i=find(L==i);
   if (shadow(shadow_i(1)))
        A=zeros(size(I_gray));
        A(shadow_i)=1;
        objet=fuzzy(A, para_fuzzy);
        s1=0.6; % double thresholds
        s2=1;
        objet_seuil=(objet>max(objet(:))*s1 & objet<max(objet(:))*s2);
        score=sum(veg_mask(objet_seuil>0.5))/length(shadow_i);
        if (score<0.05)
            shadow_clean(shadow_i)=1;
        end
   end
end
h_out=figure(5),imshow(I),hold on,drawMaskContour(shadow_clean);
figure,imshow(shadow_clean)

%% preceed first level segmentation


%% range each shadow component by size

[L_s, num_s]=rangeShadow(shadow_clean);
% figure,imshow(double(L_s==num_s(part)))
%%
building=zeros(size(I,1),size(I,2));
for part=1:40
% part=8;
part
% building segmentation for each component

shadow_i=(L_s==num_s(part));
para_fuzzy.size=10;
para_fuzzy.theta=para.theta;
para_fuzzy.l=10;

ROI=fuzzy_flat(shadow_i, para_fuzzy);
window_i=getSubwindow(ROI);
ROI=(ROI&(~veg_mask));
% figure,subplot(121),imshow(I),hold on,drawMaskContour(ROI),hold on, drawWindows(window_i,[1 0 0]),subplot(122),imshow(ROI)

%
xmin=window_i(1);
ymin=window_i(3);
I_sub=subWinImage(I,window_i);
shadow_sub=subWinImage(shadow_i,window_i);
ROI_sub=subWinImage(ROI,window_i);
veg_sub=subWinImage(veg_mask,window_i);
para_fuzzy.sigma=5;
para_fuzzy.theta=para.theta;
para_fuzzy.l=10;

objet=fuzzy(shadow_sub, para_fuzzy);
s1=0.5; % double thresholds
s2=1;
objet_seuil=(objet>max(objet(:))*s1 & objet<max(objet(:))*s2);
% figure;
% imshow(objet);
% figure,drawMask(I_sub,shadow_sub,[1 0 0]),hold on,drawMaskContour(objet_seuil&(~veg_sub))%,hold on,drawMaskContour(shadow)


forgroundMask=(objet_seuil&ROI_sub&(~shadow_sub)&(~veg_sub));
backgroundMask=(~ROI_sub)|(veg_sub);
% figure,subplot(131),imshow(I_sub),subplot(132),imshow(I_sub),hold on,drawMaskContour(forgroundMask),subplot(133),imshow(double(backgroundMask))

%
if ( sum(forgroundMask(:))>30)
    para.max_iteration=8;
    para.beta=1;%gradiant tracking parameter
    para.gamma=3;%ising regularity
    para.fc=5;
    [Ireg,evol]=grabcut(I_sub,forgroundMask,backgroundMask,para);
    % plot
%     figure(),subplot(121),imshow(I_sub);subplot(122),imshow(Ireg);
    
%     h=figure(),%drawMask(I_rgb,Ireg,[1,0,0]);
%     imshow(I_sub)
%     hold on,drawMaskContour(Ireg)
    % saveas(h,'example','pdf')
    %
    idx_reg=find(Ireg>0);
    [yreg,xreg]=ind2sub(size(Ireg),idx_reg);
    yglob=yreg+ymin-1;
    xglob=xreg+xmin-1;
    idx_glob=sub2ind(size(building),yglob,xglob);
    %
    building(idx_glob)=1;
%     figure, subplot(2,3,1),imshow(I_sub);
%     for i=1:5
%        subplot(2,3,i+1), imshow(evol(:,:,i))
%     end
end
end
%%
figure,drawMask(I,double(building),[0 0 1]);
% figure, imshow(I), hold on, drawMaskContour(building)
%% read ground truth
Igt=imread([dataPath '/Image_groundtruth.png']);
Igt=(double(rgb2gray(Igt))./255)<0.9;
figure,drawMask(I,double(Igt),[1 0 0]);




