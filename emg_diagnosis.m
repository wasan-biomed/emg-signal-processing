Fs = 1000; % تردد العينة
t = 0:1/Fs:5; % 5 ثواني

% Healthy EMG
emg_healthy = 0.5*sin(2*pi*60*t) + 0.3*sin(2*pi*120*t) + 0.2*randn(size(t));

% Myopathy: low amplitude
emg_myopathy = 0.2*sin(2*pi*60*t) + 0.1*sin(2*pi*120*t) + 0.2*randn(size(t));

% Neuropathy: irregular high bursts
emg_neuropathy = 0.8*sin(2*pi*40*t) + 0.6*sin(2*pi*90*t) + 0.5*rand(size(t));

% نجمعهم في مصفوفة
signals = {emg_healthy, emg_myopathy, emg_neuropathy};
labels = {'Healthy', 'Myopathy', 'Neuropathy'};
window_size = 200;
features = [];
class_labels = [];

for idx = 1:length(signals)
    signal = signals{idx};
    num_windows = floor(length(signal)/window_size);
    
    for i = 1:num_windows
        segment = signal((i-1)*window_size + 1 : i*window_size);
        RMS = sqrt(mean(segment.^2));
        MAV = mean(abs(segment));
        WL = sum(abs(diff(segment)));
        
        features = [features; RMS, MAV, WL]; % كل صف يمثل نافذة
        class_labels = [class_labels; idx]; % 1, 2, 3
    end
end
% تحويل البيانات إلى مصفوفة
X = features;
Y = class_labels;

% تدريب نموذج SVM
model = fitcecoc(X, Y); % multiclass SVM

% اختبار سريع على أول 5 نوافذ
predicted = predict(model, X(1:5,:));
disp('التصنيفات المتوقعة لأول 5 نوافذ:');
disp(predicted);
