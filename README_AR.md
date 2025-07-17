#  مشروع MATLAB: معالجة وتصنيف وتحكم بإشارة العضلات (EMG)

**المؤلفة: المهندسة وسن قصي حسن**  
🌐 [🇬🇧 الإنجليزية](README.md) | [🇸🇦 العربية](README_AR.md) | [🇩🇪 الألمانية](README_DE.md)

---

##  فكرة المشروع:

يعرض هذا المشروع خطوات معالجة وتحليل والتحكم في إشارات العضلات الكهربائية (EMG) باستخدام MATLAB.

ويتضمن ثلاث مراحل رئيسية:

1. **فلترة إشارة EMG** لإزالة الضوضاء.  
2. **استخلاص الخصائص وتشخيص الحالات العضلية.**  
3. **التحكم الصوري بناءً على النشاط العضلي (عرض صورة اليد مفتوحة أو مغلقة).**

> ⚠ الإشارات المستخدمة هنا **مولّدة يدويًا داخل MATLAB** وليست حقيقية من أجهزة استشعار.

---

##  المرحلة 1: توليد وفلترة إشارة EMG

###  الهدف:

* محاكاة إشارة عضلية تحتوي على ترددات في نطاق 20–450 هرتز.  
* تمرير الإشارة خلال فلتر Butterworth نطاق تمرير (Bandpass).

###  كود MATLAB:

```matlab
Fs = 1000; % التردد العيناتي
t = 0:1/Fs:5; % مدة 5 ثوانٍ

% توليد إشارة EMG اصطناعية
emg_clean = 0.5 * sin(2*pi*60*t) + 0.3 * sin(2*pi*150*t);
noise = 0.2 * randn(size(t));
emg_raw = emg_clean + noise;

% رسم الإشارة قبل الفلترة
figure;
plot(t, emg_raw);
title('إشارة EMG الخام');
xlabel('الزمن (ثانية)'); ylabel('السعة');

% تطبيق فلتر تمرير نطاق 20–450 هرتز
[b, a] = butter(4, [20 450]/(Fs/2), 'bandpass');
emg_filtered = filtfilt(b, a, emg_raw);

% رسم الإشارة بعد الفلترة
figure;
plot(t, emg_filtered);
title('إشارة EMG بعد الفلترة');
xlabel('الزمن (ثانية)'); ylabel('السعة');
```

---

##  المرحلة 2: التصنيف (التشخيص)

###  الهدف:

استخلاص خصائص رقمية من الإشارة المفلترة وتصنيفها إلى إحدى الحالات التالية:

- **عضلات سليمة (Healthy)**  
- **اعتلال عضلي (Myopathy)**  
- **اعتلال عصبي (Neuropathy)**

### الخصائص المستخرجة:

- **RMS** الجذر التربيعي للقيمة المتوسطة  
- **MAV** متوسط القيمة المطلقة  
- **WL** طول شكل الموجة

###  كود استخراج الخصائص:

```matlab
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
title('الخصائص المستخرجة من EMG');
xlabel('الزمن (ثانية)'); ylabel('قيمة الخاصية');
```

---

###  كود التصنيف والمحاكاة:

```matlab
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

% تدريب المصنف
X = features; Y = class_labels;
model = fitcecoc(X, Y);

% اختبار تنبؤ سريع
predicted = predict(model, X(1:5,:));
disp('التسميات المتوقعة لأول 5 نوافذ:');
disp(predicted);
```

---

##  المرحلة 3: التحكم البصري اعتمادًا على العضلات

###  الهدف:

عرض صورة اليد مفتوحة أو مغلقة حسب قيمة MAV لكل مقطع من الإشارة.

###  الصور المطلوبة:

- `hand_open.png` ← يد مفتوحة  
- `hand_closed.png` ← يد مغلقة  

> ضَع هذه الصور في نفس مجلد السكربت.

###  كود التحكم:

```matlab
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
        title_txt = '🔓 عضلة نشطة ← يد مفتوحة';
    else
        img = imread('hand_closed.png');
        title_txt = '🔒 عضلة غير نشطة ← يد مغلقة';
    end

    imshow(img);
    title(title_txt, 'FontSize', 14);
    pause(0.1);
end
```

---

##  الملخص:

-  تم توليد إشارة EMG يدويًا باستخدام `sin` و `randn` في MATLAB.  
-  تم فلترتها باستخدام فلتر تمرير نطاق 20–450 هرتز.  
-  تم استخراج الخصائص (RMS، MAV، WL) واستخدامها لتصنيف الحالات.  
-  تم بناء نظام تحكم بصري بسيط يغير الصور حسب نشاط العضلة.

>  **هذا المشروع تم تنفيذه وتوثيقه بالكامل من قبل المهندسة الطبية وسن قصي حسن باستخدام MATLAB Online.**  
> يُعد هذا المشروع أساسًا لتطويرات لاحقة مثل (واجهة رسومية، العمل بالزمن الحقيقي، ربط مع Arduino) أو كأداة تعليمية لمشروع تخرج أو تدريب.
