%Signal and filter Parameters 
clear all, close all, clc
len = 10000;


[u, Fs] = audioread('GUIT_NO_AMP.aif'); 
[d, Fs] = audioread('GUIT_AMP_CLEAN.aif'); 

u = u(:,1);
d = d(:,1);

%Computation of the autocorrelation matrix
r = xcorr(u);
r = r(100:150);
R = toeplitz(r);
disp('Auto-correlation matrix:');
display(R);

%Computation of cross-correlation vector
p_ = xcorr(u,d);
p = p_(50:100);
disp('Cross-correlation vector:');
display(p);

%Wiener Optimum filter
wo = R\p;
disp('Wiener-filter solution:');
display(wo);

%Filtered signal
out = filter(wo,1,u);

sound(out,Fs); 



