function Ireg=graph_cut_1Dgaussian(I,m1,m2,beta,gamma)
m1_toC=[m1.pi(:),m1.mu(:),m1.sigma(:)]
m2_toC=[m2.pi(:),m2.mu(:),m2.sigma(:)]
Ireg=min_exact_binary_1Dgaussian_graph_cut(I,m1_toC,m2_toC,beta,gamma);
end