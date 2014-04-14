function [ mask ] = addGaussian( m1,sigma1, mask )
%ADDGAUSSIAN Summary of this function goes here
%   Detailed explanation goes here
mask=(m1*ones(size(mask))+sigma1*randn(size(mask))).*mask;

mask(mask>1)=1;
mask(mask<0)=0;

end

