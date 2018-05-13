clear all, close all, clc

[u, Fs] = audioread('GUIT_NO_AMP.aif'); 
[d, Fs] = audioread('GUIT_AMP_CLEAN.aif'); 

u = u(:,1);
d = d(:,1);

u_ = u(1:10*Fs);
d = d(1:10*Fs);

U = fft(u_);
D = fft(d);

magU = abs(U);
magD = abs(D);

figure;
plot(magU);
hold on;
plot(magD);

H = D./U;

h = ifft(H);
[S, w] = freqz(h,1);
figure;
plot(w/pi, abs(S));

out = filter(h,1,u);

%%sound(out,Fs); 





