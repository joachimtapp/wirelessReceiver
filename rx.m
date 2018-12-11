function [rx_bits conf] = rx(rx_signal,conf,k)
% Digital Receiver
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete causal
%   receiver in digital domain.
%
%   rxsignal    : received signal
%   conf        : configuration structure
%   k           : frame index
%
%   Outputs
%
%   rxbits      : received bits
%   conf        : configuration structure
%
data_length=conf.nsyms;
% put to baseband and filter
time = 0:1/conf.f_s:(length(rx_signal)-1)/conf.f_s;

rx_shaped=rx_signal.*exp(-1j*2*pi*conf.f_c.*time.');
rx_shaped=2*lowpass(rx_shaped,conf);

% %noise
%  % convert SNR from dB to linear
%         SNR=20;
%         SNRlin = 10^(SNR/10);
%         % add awgn channel
%         rx_shaped = rx_shaped + sqrt(1/(2*SNRlin)) * (randn(size(rx_shaped)) + 1i*randn(size(rx_shaped)) ); 
% 
%         % Create phase noise
%         theta_n = zeros(length(rx_shaped),1);
%         theta_n(1) = 2*pi*rand(1);
%         sigmaDeltaTheta = 0.004;
%         for i = 2 : length(rx_shaped)
%            theta_n(i) = mod(theta_n(i-1) + sigmaDeltaTheta*randn,2*pi);
%         end
% 
%         % Apply phase noise
%         rx_shaped = rx_shaped.*exp(1j*theta_n);
% 
% 
% 
%match filter
rolloff_factor=0.22;
g_RRC=rrc(conf.os_factor,rolloff_factor,10*conf.os_factor);
rx_symb_up=conv(rx_shaped,g_RRC,'same');

[data_idx theta magnitude] = frame_sync(rx_symb_up,conf.os_factor,conf);


% rx_symb = zeros(data_length, 1); % The payload data symbols
% eps_hat = zeros(data_length, 1);     % Estimate of the timing error
theta_hat = zeros(data_length+1, 1);   % Estimate of the carrier phase
theta_hat(1) = theta;

%downsample
rx_symb=downsample(rx_symb_up(data_idx:data_idx+conf.nsyms*conf.os_factor-1),conf.os_factor);
data_idx

%invert canal
%  rx_symb = 1/magnitude*exp(-1j*theta) * rx_symb;


 for k = 1 : data_length
%     
%     % timing estimator
%     eps_hat(k) = timing_estimator(rx_symb_up(data_idx : data_idx + conf.os_factor - 1));
%     opt_sampling_inst = eps_hat(k) * os_factor;
%     
%    
%     y = rx_symb_up(data_idx + floor(opt_sampling_inst) - 1 : data_idx + floor(opt_sampling_inst) + 2);
%     rx_symb(k) = cubic_interpolator(y, opt_sampling_inst - floor(opt_sampling_inst));
% 
%     
%     
    % Phase estimation    
    % Apply viterbi-viterbi algorithm
    deltaTheta = 1/4*angle(-rx_symb(k)^4) + pi/2*(-1:4);
    
    % Unroll phase
    [~, ind] = min(abs(deltaTheta - theta_hat(k)));
    theta = deltaTheta(ind);
    

    % Lowpass filter phase
    theta_hat(k+1) = mod(0.01*theta + 0.99*theta_hat(k), 2*pi);

    % Phase and amplitude correction 
    rx_symb(k) =1/magnitude* rx_symb(k) * exp(-1j * theta_hat(k+1));   % ...and rotate the current symbol accordingly
    
%     data_idx = data_idx + os_factor;
 end

%demapping
if conf.modulation_order==1
  rx_bits= (1-sign(real(rx_symb)))/2;
end
if conf.modulation_order==2
    Map=1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
    Map=(Map.'*ones(1,conf.nsyms)).';
    rx_vec=rx_symb*ones(1,4);
    [~,ind]=min(abs(rx_vec-Map),[],2);

    rx_bits=de2bi(ind-1,2,'left-msb');
    rx_bits=reshape(rx_bits',[conf.nbits,1]);
end

% plot(tx_bits,'x'),hold on
% plot(rx_bits)
% legend('tx','rx')
% ylim([-1.1,1.1])
return