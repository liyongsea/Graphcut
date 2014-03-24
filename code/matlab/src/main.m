 %%read data
function main
close all
clear all
%%
dataPath='/home/li/MVA/Graphcut_shadow/data';
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
para.method='croissance';
% para.k=5;
shadow=getShadowMask(I_sub,para);

h_out=figure(5),I_out=drawMask(I_sub,shadow,[1,0,0]);
%%
%binary graph cut
% gamma=0.2;
% m1= 0.1;
% m2= 0.8;
% Ireg=min_exacte_binaire_graph_cut_a_completer(double(I_sub),m1,m2,gamma);
% figure(),imshow(Ireg)
%%
% user_define=0;
% if (user_define)
%     windows_for=getSubSample(I_sub,[1 0 0]);
%     windows_back=getSubSample(I_sub,[0 0 1]);
%     save([dataPath '/forground_win.mat'],'windows_for','-ASCII')
%     save([dataPath '/background_win.mat'],'windows_back','-ASCII')
% else 
%     windows_for=load([dataPath '/forground_win.mat'],'-ASCII')
%     windows_back=load([dataPath '/background_win.mat'],'-ASCII')
% end
% h_out, hold on;
% drawWindows(windows_for,[1,0,0]);
% drawWindows(windows_back,[0,0,1]);
% %%
% forground=[];
% for i=1:size(windows_for)
%     sample=I_sub(windows_for(i,1):windows_for(i,2),windows_for(i,3):windows_for(i,4));
%     forground=[forground;sample(:)];
% end
% background=[];
% for i=1:size(windows_back)
%     sample=I_sub(windows_back(i,1):windows_back(i,2),windows_back(i,3):windows_back(i,4));
%     background=[background;sample(:)];
% end
% figure,
% subplot(121),hist(forground,255)
% subplot(122),hist(background,255)
% %%
% 
% for_mixture=GaussianMixture(forground,5);
% back_mixture=GaussianMixture(background,5);
% %%
% Ireg=graph_cut_1Dgaussian(double(I_sub),m1,m2,gamma);

end

