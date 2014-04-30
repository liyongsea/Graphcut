function [ objet ] = fuzzy_flat( shadow, para )
% get the fuzzy landscape given the shadow
% para should contain the following field :
%    theta: direction of the shadow 
%    l : length of the shadow 
%    s : size of ROI
l=para.l;
theta=para.theta;
s=para.size;

m_se_rev=computeSE(l*s,theta+pi);


% shadow_C=1-shadow;
% shadow_C=double(shadow_C);
% 
% se_per=strel([1,1,1;1,0,1;1,1,1]);
% shadow_per=imdilate(shadow,se_per)&~shadow;
% shadow_per=double(shadow_per);
% my code (Jia LI)
% disk=strel('disk', 1, 4);
% shadow_inter=imerode(shadow,disk);
% shadow_per=shadow-shadow_inter;
% figure,imshow(shadow_per);

% m_se_falt=ones(s,s);

% m_se_fuzzy=m_se_rev.*m_se_falt;

se_fuzzy=strel(m_se_rev);
% figure,imshow(m_se_fuzzy)
objet=imdilate(shadow,se_fuzzy);
% figure;
% imagesc(objet);colormap(gray)

end



