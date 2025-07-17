# 📁 MATLAB Project: EMG Signal Processing, Classification, and Control

✍️ **Author: Eng. Wasan Qusay Hasan (Faiqa)**

---

## 🎯 Project Idea:

This project presents a complete pipeline for **processing, analyzing, and controlling** based on EMG (Electromyography) signals using MATLAB.

It includes three main stages:

1. **Filtering the EMG signal** to remove noise.  
2. **Feature extraction and diagnosis** of muscular conditions.  
3. **Muscle-based control** to display images (hand open/closed) depending on activity.

> ⚠️ The EMG signals used are **simulated/generated manually in MATLAB**, not recorded from real hardware.

---

## ✅ Stage 1: EMG Signal Generation and Filtering

### 🎯 Goal:

* Simulate a noisy EMG signal containing frequency components in the 20–450 Hz range.  
* Filter the signal using a bandpass Butterworth filter.

### 🔢 MATLAB Code:

```matlab
Fs = 1000; % Sampling frequency
t = 0:1/Fs:5; % 5 seconds

% Generate synthetic EMG signal
emg_clean = 0.5 * sin(2*pi*60*t) + 0.3 * sin(2*pi*150*t);
noise = 0.2 * randn(size(t));
emg_raw = emg_clean + noise;

% Plot raw signal
figure;
plot(t, emg_raw);
title('Raw EMG Signal');
xlabel('Time (s)'); ylabel('Amplitude');

% Bandpass filter (20–450 Hz)
[b, a] = butter(4, [20 450]/(Fs/2), 'bandpass');
emg_filtered = filtfilt(b, a, emg_raw);

% Plot filtered signal
figure;
plot(t, emg_filtered);
title('Filtered EMG Signal');
xlabel('Time (s)'); ylabel('Amplitude');


✅ Stage 2: Diagnosis (Classification)
🎯 Goal:
Extract meaningful features from the filtered signal and classify it into one of three conditions:

Healthy

Myopathy

Neuropathy

Neuropathy

📊 Extracted Features:
RMS (Root Mean Square)

MAV (Mean Absolute Value)

WL (Waveform Length)

🔢 Feature Extraction Code:
window_size = 200;
num_windows = floor(length(emg_filtered)/window_size);
RMS = zeros(1, num_windows);
MAV = zeros(1, num_windows);
WL = zeros(1, num_windows);

for i = 1:num_windows
    segment = emg_filtered((i-1)*window_size + 1 : i*window_size);
    RMS(i) = sqrt(mean(segment.^2));
    MAV(i) = mean(abs(segment));
    WL(i) = sum(abs(diff(segment)));
end

time_axis = (0:num_windows-1) * (window_size / Fs);

figure;
plot(time_axis, RMS, 'r'); hold on;
plot(time_axis, MAV, 'g');
plot(time_axis, WL, 'b');
legend('RMS', 'MAV', 'WL');
title('Extracted EMG Features');
xlabel('Time (s)'); ylabel('Feature Value');
🔢 Simulating & Classifying EMG Conditions:
% Simulated signals
Fs = 1000;
t = 0:1/Fs:5;

emg_healthy = 0.5*sin(2*pi*60*t) + 0.3*sin(2*pi*120*t) + 0.2*randn(size(t));
emg_myopathy = 0.2*sin(2*pi*60*t) + 0.1*sin(2*pi*120*t) + 0.2*randn(size(t));
emg_neuropathy = 0.8*sin(2*pi*40*t) + 0.6*sin(2*pi*90*t) + 0.5*rand(size(t));

signals = {emg_healthy, emg_myopathy, emg_neuropathy};
labels = {'Healthy', 'Myopathy', 'Neuropathy'};

features = [];
class_labels = [];

for idx = 1:length(signals)
    signal = signals{idx};
    for i = 1:floor(length(signal)/window_size)
        segment = signal((i-1)*window_size + 1 : i*window_size);
        RMS = sqrt(mean(segment.^2));
        MAV = mean(abs(segment));
        WL = sum(abs(diff(segment)));
        features = [features; RMS, MAV, WL];
        class_labels = [class_labels; idx];
    end
end

% Train classifier
X = features; Y = class_labels;
model = fitcecoc(X, Y);

% Quick prediction test
predicted = predict(model, X(1:5,:));
disp('Predicted labels for first 5 windows:');
disp(predicted);
✅ Stage 3: Muscle-Based Control (Visual)
🎯 Goal:
Display a different image (open or closed hand) depending on the MAV value of the signal segment.

🖼️ Required Images:
hand_open.png

hand_closed.png

These images should be placed in the same directory as the script.

🔢 Control Code:
Fs = 1000;
t = 0:1/Fs:5;
emg_signal = 0.5*sin(2*pi*70*t) + 0.3*sin(2*pi*140*t) + 0.2*randn(size(t));
window_size = 200;
num_windows = floor(length(emg_signal)/window_size);
threshold = 0.25;

figure;
for i = 1:num_windows
    segment = emg_signal((i-1)*window_size + 1 : i*window_size);
    MAV = mean(abs(segment));
    
    if MAV > threshold
        img = imread('hand_open.png');
        title_txt = '🔓 Muscle Active → Hand Open';
    else
        img = imread('hand_closed.png');
        title_txt = '🔒 Muscle Inactive → Hand Closed';
    end

    imshow(img);
    title(title_txt, 'FontSize', 14);
    pause(0.1);
end
🧾 Summary:
✅ The EMG signal is generated manually in MATLAB using sin and randn.

✅ It is filtered with a bandpass filter between 20–450 Hz.

✅ Features (RMS, MAV, WL) are extracted and used to classify simulated cases.

✅ A visual control system is implemented that reacts to muscle activity by changing images.

👩‍🔬 This project was fully authored, coded, and documented by biomedical engineer Wasan Qusay Hasan using MATLAB Online.
It is intended as a base for further development (GUI, real-time, Arduino interface) or academic use (graduation project, training portfolio).
