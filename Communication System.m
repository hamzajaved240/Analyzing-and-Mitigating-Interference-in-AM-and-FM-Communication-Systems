% Communication Systems Project
% Phase 1: Understanding and Simulating AM and FM Modulation and Demodulation

% Task 1: Generate a carrier signal and a modulating signal (audio signal of your own recorded voice)
fs = 44100; % Sampling frequency
t = 0:1/fs:5-1/fs; % Time vector for 5 seconds

% Generate a carrier signal
fc = 10000; % Carrier frequency in Hz
carrier = cos(2*pi*fc*t);

% Record and load audio signal
% Use 'audiorecorder' function to record your voice or load a pre-recorded audio file
recObj = audiorecorder(fs, 16, 1);
disp('Start speaking.')
recordblocking(recObj, 5);
disp('End of Recording.');
modulating_signal = getaudiodata(recObj);

% Normalize the modulating signal
modulating_signal = modulating_signal / max(abs(modulating_signal));

% Task 2: AM Modulation
modulated_signal_am = (1 + modulating_signal') .* carrier;

% Task 3: FM Modulation
kf = 2 * pi * 75; % Frequency sensitivity
modulated_signal_fm = cos(2*pi*fc*t + kf * cumsum(modulating_signal') / fs);

% Task 4: Add Gaussian noise to simulate real-world transmission
noisy_signal_am = awgn(modulated_signal_am, 20, 'measured');
noisy_signal_fm = awgn(modulated_signal_fm, 20, 'measured');

% Task 5: AM Demodulation
demodulated_signal_am = noisy_signal_am .* carrier; % Product demodulation
[b, a] = butter(6, fc/(fs/2)); % Low-pass filter design
demodulated_signal_am = filter(b, a, demodulated_signal_am);

% Task 6: FM Demodulation
demodulated_signal_fm = fmdemod(noisy_signal_fm, fc, fs, 75);

% Task 7: Plot the original, modulated, transmitted (with noise), and demodulated signals
figure;
subplot(6,1,1);
plot(t, modulating_signal);
title('Original Modulating Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(6,1,2);
plot(t, modulated_signal_am);
title('AM Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(6,1,3);
plot(t, noisy_signal_am);
title('AM Transmitted Signal with Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(6,1,4);
plot(t, demodulated_signal_am);
title('AM Demodulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(6,1,5);
plot(t, noisy_signal_fm);
title('FM Transmitted Signal with Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(6,1,6);
plot(t, demodulated_signal_fm);
title('FM Demodulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Phase 2: Introducing Interference

% Task 1: Generate Interference Signal
fc_interference = 12000; % Interference carrier frequency
interference_am = cos(2*pi*fc_interference*t) .* (0.5 * modulating_signal');
interference_fm = cos(2*pi*fc_interference*t + kf * cumsum(0.5 * modulating_signal') / fs);

% Task 2: Combine Signals
interference_signal_am = noisy_signal_am + interference_am;
interference_signal_fm = noisy_signal_fm + interference_fm;

% Task 3: Visualize the spectrum of the noisy and interference-laden signal
figure;
subplot(2,1,1);
pwelch(noisy_signal_am, [], [], [], fs, 'centered');
title('Spectrum of Noisy AM Signal');

subplot(2,1,2);
pwelch(interference_signal_am, [], [], [], fs, 'centered');
title('Spectrum of Interference-Laden AM Signal');

figure;
subplot(2,1,1);
pwelch(noisy_signal_fm, [], [], [], fs, 'centered');
title('Spectrum of Noisy FM Signal');

subplot(2,1,2);
pwelch(interference_signal_fm, [], [], [], fs, 'centered');
title('Spectrum of Interference-Laden FM Signal');

% Task 4: Analyze how the presence of this interference affects the demodulated output
interference_demodulated_am = interference_signal_am .* carrier; % Product demodulation
interference_demodulated_am = filter(b, a, interference_demodulated_am);

interference_demodulated_fm = fmdemod(interference_signal_fm, fc, fs, 75);

% Phase 3: Interference Mitigation Techniques

% Task 1: Implement a notch filter to mitigate interference
wo = fc_interference/(fs/2);  % Normalized frequency
bw = wo/35;                   % Bandwidth
[b_notch, a_notch] = iirnotch(wo, bw);

% Task 2: Apply the notch filter
filtered_signal_am = filter(b_notch, a_notch, interference_signal_am);
filtered_signal_fm = filter(b_notch, a_notch, interference_signal_fm);

% Demodulate the filtered signals
filtered_demodulated_am = filtered_signal_am .* carrier; % Product demodulation
filtered_demodulated_am = filter(b, a, filtered_demodulated_am);

filtered_demodulated_fm = fmdemod(filtered_signal_fm, fc, fs, 75);

% Task 3: Compare the output signals with and without the application of the mitigation techniques
figure;
subplot(2,1,1);
plot(t, interference_demodulated_am);
title('AM Demodulated Signal with Interference');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, filtered_demodulated_am);
title('AM Demodulated Signal after Interference Mitigation');
xlabel('Time (s)');
ylabel('Amplitude');

figure;
subplot(2,1,1);
plot(t, interference_demodulated_fm);
title('FM Demodulated Signal with Interference');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, filtered_demodulated_fm);
title('FM Demodulated Signal after Interference Mitigation');
xlabel('Time (s)');
ylabel('Amplitude');

% Task 4: Evaluate the performance of each technique using metrics such as Signal-to-Noise Ratio (SNR)
% Calculating noise by subtracting the modulated signal from the noisy/interference signals
noise_no_interference_am = noisy_signal_am - modulated_signal_am;
noise_with_interference_am = interference_signal_am - modulated_signal_am;
noise_after_filtering_am = filtered_signal_am - modulated_signal_am;

noise_no_interference_fm = noisy_signal_fm - modulated_signal_fm;
noise_with_interference_fm = interference_signal_fm - modulated_signal_fm;
noise_after_filtering_fm = filtered_signal_fm - modulated_signal_fm;

% Calculate SNR manually
snr_no_interference_am = 10 * log10(sum(modulating_signal.^2) / sum(noise_no_interference_am.^2));
snr_interference_am = 10 * log10(sum(modulating_signal.^2) / sum(noise_with_interference_am.^2));
snr_filtered_am = 10 * log10(sum(modulating_signal.^2) / sum(noise_after_filtering_am.^2));

snr_no_interference_fm = 10 * log10(sum(modulating_signal.^2) / sum(noise_no_interference_fm.^2));
snr_interference_fm = 10 * log10(sum(modulating_signal.^2) / sum(noise_with_interference_fm.^2));
snr_filtered_fm = 10 * log10(sum(modulating_signal.^2) / sum(noise_after_filtering_fm.^2));

fprintf('SNR of noisy AM signal: %.2f dB\n', snr_no_interference_am);
fprintf('SNR of AM signal with interference: %.2f dB\n', snr_interference_am);
fprintf('SNR of AM signal after mitigation: %.2f dB\n', snr_filtered_am);

fprintf('SNR of noisy FM signal: %.2f dB\n', snr_no_interference_fm);
fprintf('SNR of FM signal with interference: %.2f dB\n', snr_interference_fm);
fprintf('SNR of FM signal after mitigation: %.2f dB\n', snr_filtered_fm);

% Phase 4: Documentation and Reporting
% Add comments and function descriptions within the code as necessary.
