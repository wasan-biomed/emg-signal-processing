Fs = 1000;
t = 0:1/Fs:5;

% توليد إشارة EMG وهمية
emg_signal = 0.5*sin(2*pi*70*t) + 0.3*sin(2*pi*140*t) + 0.2*randn(size(t));

% إعدادات النافذة والعتبة
window_size = 200;
num_windows = floor(length(emg_signal)/window_size);
threshold = 0.25;

% حلقه التحكم
for i = 1:num_windows
    segment = emg_signal((i-1)*window_size + 1 : i*window_size);
    MAV = mean(abs(segment));
    
    if MAV > threshold
        disp(['🔓 نافذة ', num2str(i), ': العضلة نشطة → فتح اليد']);
    else
        disp(['🔒 نافذة ', num2str(i), ': العضلة خاملة → غلق اليد']);
    end
    
    pause(0.05); % وقت بسيط لعرض النتائج تدريجيًا
end
Fs = 1000;
t = 0:1/Fs:5;

% توليد إشارة EMG وهمية
emg_signal = 0.5*sin(2*pi*70*t) + 0.3*sin(2*pi*140*t) + 0.2*randn(size(t));

% إعدادات النافذة والعتبة
window_size = 200;
num_windows = floor(length(emg_signal)/window_size);
threshold = 0.25;

% عرض أولي
fig = figure;
for i = 1:num_windows
    segment = emg_signal((i-1)*window_size + 1 : i*window_size);
    MAV = mean(abs(segment));

    if MAV > threshold
        img = imread('hand_open.png');
        title_txt = '🔓 العضلة نشطة → فتح اليد';
    else
        img = imread('hand_closed.png');
        title_txt = '🔒 العضلة خاملة → غلق اليد';
    end

    imshow(img);
    title(title_txt, 'FontSize', 14);
    pause(0.1); % وقت للعرض قبل التحديث
end
