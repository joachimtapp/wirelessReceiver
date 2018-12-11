function [tx_signal conf] = tx(tx_bits,conf,k)
% Digital Transmitter
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete transmitter
%   consisting of:
%       - modulator
%       - pulse shaping filter
%       - up converter
%   in digital domain.
%
%   txbits  : Information bits
%   conf    : Universal configuration structure
%   k       : Frame index
%


% dummy 400Hz sinus generation
% time = 1:1/conf.f_s:4;
% signal = 0.3*sin(2*pi*400 * time.');

preamble = 1 - 2*lfsr_framesync(conf.npreamble);
%BPSK mapper
if conf.modulation_order==1
    tx_symb=1 - 2*tx_bits;  
end

%QPSK mapper
if conf.modulation_order==2
    tx_bits_2=reshape(tx_bits,2,length(tx_bits)/2).';

    %grey mapping
    Map=1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
    tx_symb = Map(bi2de(tx_bits_2,'left-msb')+1).';
end
%concatenate preamble with signal
tx_symb = vertcat(preamble,tx_symb);

%oversampling
tx_symb_up=upsample(tx_symb,conf.os_factor);

% pulse shaping
rolloff_factor=0.22;
g_RRC=rrc(conf.os_factor,rolloff_factor,10*conf.os_factor);

tx_shaped=conv(tx_symb_up,g_RRC,'same');

%put to passband
time = 0:1/conf.f_s:(length(tx_shaped)-1)/conf.f_s;
tx_signal=real(tx_shaped.*exp(1j*2*pi*conf.f_c.*time.'));

return
