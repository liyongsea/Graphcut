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
            sigma(:,:,j)=trace(0.5*diffXmu*((repmat(Rj,[1 dim]).*diffXmu)'))/sR*diag([1 1]) ;
        end
    end
    %===========E-step
    for j=1:K
    distribute_j.mn=mu(j,:)';
    distribute_j.cov=sigma(:,:,j);
    P(:,j)=evaluate_gaussian(X',distribute_j);
    end
    Palpha=P.*repmat(alpha,[N,1]);
    Palpha_sum=sum(Palpha,2);
    R=Palpha./repmat(Palpha_sum,[1,K]);
    like=[like sum(log(sum(Palpha,2)))];
end
figure,plot([1:1:L],like);

end
