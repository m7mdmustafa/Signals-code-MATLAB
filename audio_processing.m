clc;
clear;
close all;

% Read audio file
[x, Fs] = audioread('names.wav');

% Convert stereo audio to mono
if size(x, 2) == 2
    x = mean(x, 2);
end

% Time vector
N = length(x);
t = (0:N-1) / Fs;

% =========================
% Time Domain
% =========================

figure;
plot(t, x);
xlabel('Time (sec)');
ylabel('Amplitude');
title('Audio Signal in Time Domain');
grid on;

% Energy in time domain
Energy_time = sum(abs(x).^2);

disp('Energy in Time Domain:');
disp(Energy_time);

% =========================
% Frequency Domain
% =========================

X = fft(x);
X_shift = fftshift(X);

f = (-N/2 : N/2-1) * (Fs/N);

figure;
plot(f, abs(X_shift));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Domain Representation');
grid on;

% Energy in frequency domain
Energy_freq = sum(abs(X).^2) / N;

disp('Energy in Frequency Domain:');
disp(Energy_freq);

% Difference between energies
Difference = abs(Energy_time - Energy_freq);

disp('Difference between energies:');
disp(Difference);

% =========================
% Peak Frequency
% =========================

magnitude = abs(X_shift);

[~, index] = max(magnitude);

f_peak = f(index(1));

disp('Peak Frequency:');
disp(f_peak);

% =========================
% Frequency Notch Filtering
% =========================

BW_values = [50 150 300];

for k = 1:length(BW_values)

    BW = BW_values(k);

    % Copy original spectrum
    X_filtered = X_shift;

    % Define notch region around +f_peak and -f_peak
    notch_region = abs(f - f_peak) < BW | ...
                   abs(f + f_peak) < BW;

    % Remove selected frequencies
    X_filtered(notch_region) = 0;

    % Plot filtered spectrum
    figure;
    plot(f, abs(X_filtered));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(['Filtered Spectrum - BW = ' num2str(BW)]);
    grid on;

    % Convert back to time domain
    X_inverse = ifftshift(X_filtered);
    x_filtered = real(ifft(X_inverse));

    % Plot filtered signal
    figure;
    plot(t, x_filtered);
    xlabel('Time (sec)');
    ylabel('Amplitude');
    title(['Filtered Signal - BW = ' num2str(BW)]);
    grid on;

    % Save filtered audio
    filename = ['filtered_BW_' num2str(BW) '.wav'];

    audiowrite(filename, x_filtered, Fs);

end