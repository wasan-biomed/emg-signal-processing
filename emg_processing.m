% إعداد البيئة
Fs = 1000; % تردد العينة (Hz)
t = 0:1/Fs:5; % 5 ثواني

% توليد إشارة EMG وهمية (Noise + موجات عضلية عشوائية)
emg_clean = 0.5 * sin(2*pi*60*t) + 0.3 * sin(2*pi*150*t); % إشارة عضلية
noise = 0.2 * randn(size(t)); % ضوضاء بيضاء
emg_raw = emg_clean + noise;

% عرض الإشارة الأصلية
figure;
plot(t, emg_raw);
title('Raw EMG Signal (Simulated)');
xlabel('Time (s)');
ylabel('Amplitude');

% تصميم فلتر تمرير نطاقي 20-450 Hz
low_cutoff = 20;
high_cutoff = 450;
[b, a] = butter(4, [low_cutoff, high_cutoff]/(Fs/2), 'bandpass');

% تطبيق الفلتر
emg_filtered = filtfilt(b, a, emg_raw);

% عرض الإشارة بعد الفلترة
figure;
plot(t, emg_filtered);
title('Filtered EMG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
% تقسيم الإشارة إلى نوافذ (windows) ثابتة الطول
window_size = 200; % عدد العينات في كل نافذة (مثلاً 200 عينة = 0.2 ثانية عند Fs=1000)
num_windows = floor(length(emg_filtered)/window_size);

% تهيئة المتغيرات
RMS = zeros(1, num_windows);
MAV = zeros(1, num_windows);
WL = zeros(1, num_windows);

% حساب الخصائص لكل نافذة
for i = 1:num_windows
    segment = emg_filtered((i-1)*window_size + 1 : i*window_size);

    RMS(i) = sqrt(mean(segment.^2));                % Root Mean Square
    MAV(i) = mean(abs(segment));                    % Mean Absolute Value
    WL(i) = sum(abs(diff(segment)));                % Waveform Length
end

% رسم الخصائص
time_axis = (0:num_windows-1) * (window_size / Fs);

figure;
plot(time_axis, RMS, 'r', 'DisplayName', 'RMS');
hold on;
plot(time_axis, MAV, 'g', 'DisplayName', 'MAV');
plot(time_axis, WL, 'b', 'DisplayName', 'WL');
legend;
title('Extracted EMG Features per Window');
xlabel('Time (s)');
ylabel('Feature Value');
