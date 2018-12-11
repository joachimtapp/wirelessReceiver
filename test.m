clc
clear
time = 1:1/48000:4;
txsignal = 0.3*sin(2*pi*400 * time.');

fc=4000;

txsignal_passband=txsignal.*exp(j*2*pi*fc.*time.');