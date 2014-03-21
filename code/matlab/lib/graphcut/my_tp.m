%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Illustration cours "Champs de Markov et Graph-cuts"%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

I=imread('Ibruitee.png');
newimage(I)


S=imread('IoriginaleBW.png');
newimage(S);

%pour forcer l'histogramme a utiliser 255 valeurs pour le vecteur v
utiliser les commandes 
bins=0:255;
figure,plot(hist(v,bins)); 

%analyse du bruit de l'image
%%




% donnees en entree a definir
% image bruitee 
beta= 10;
m1= 0;
m2=255 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% recuit simule - Programme a completer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image debruitee ; � initialiser
Srs=;
% Temperature ; � initialiser
T=;
figure;
for n=1:500,
	Srs=echantillonneur_Gibbs_a_completer(double(I),Srs,T,m1,m2,beta);
    imagesc(Srs); colormap(gray)
    title(sprintf('Echantillonnage, T=%.3f, iter %d',T,n));
    drawnow;
    % decroissance de la temperature ; a completer
    T=;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graph cut binaire - Programme a completer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
beta=10000;
mex min_exacte_binaire_graph_cut_a_completer.cpp
Ireg=min_exacte_binaire_graph_cut_a_completer(double(I),m1,m2,beta);
figure(),imshow(Ireg)


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% alpha-expansion - Programme a completer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label=0:255
mex min_approchee_a_expansion_graph_cut_a_completer.cpp
I_alpha=min_approchee_a_expansion_graph_cut_a_completer(double(I),label,100);



