function [mu alpha sigma P]=expectationMaximization(X,R,L,flag)
% EM algorithm for mixture of gaussian
% X is the N*dim data vector, R is N*K vector, a first assignment estimated from k means
% where K is the number of classes. L is the iteration step.
% flag =0 : isotope gaussian
P=zeros(size(R));
dim=size(X,2);
N=size(X,1);
K=size(R,2);
mu=zeros(K,dim);
alpha=zeros(1,K);
sigma=zeros(dim,dim,K);
like=[];
elpsi=0.1^12;
for l=1:L
    %===========M-step
    for j=1:K
        Rj=R(:,j);
        sR=sum(Rj);
        mu(j,:)=sum(repmat(Rj,[1 dim]).*X)/sR;
        alpha(j)=sR/N;
        diffXmu=X-repmat(mu(j,:),[N,1]);
        if (flag)
            sigma(:,:,j)=((repmat(Rj,[1 dim]).*diffXmu)'*diffXmu)/sR;
        else
            sigma(:,:,j)=trace(0.5*diffXmu*((repmat(Rj,[1 dim]).*diffXmu)'))/sR*eye(dim) ;
        end
    end
    %===========E-step
    for j=1:K
    distribute_j.mn=mu(j,:)';
    distribute_j.cov=sigma(:,:,j);
    if (abs(det(sigma(:,:,j)))<elpsi)
        distribute_j.cov=0.001*eye(size(sigma(:,:,j)));
        sigma(:,:,j)=0.001*eye(size(sigma(:,:,j)));
    end
    P(:,j)=evaluate_gaussian(X',distribute_j);
    end
    Palpha=P.*repmat(alpha,[N,1]);
    Palpha_sum=sum(Palpha,2);
    R=Palpha./repmat(Palpha_sum,[1,K]);
    like=[like sum(log(sum(Palpha,2)))];
end
%figure,plot([1:1:L],like);

end
