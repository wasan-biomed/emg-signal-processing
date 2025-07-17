#  MATLAB-Projekt: EMG-Signalverarbeitung, Klassifikation und Steuerung

 **Autorin: Ing. Wasan Qusay Hasan **  
 [🇬🇧 Englisch](README.md) | [🇸🇦 Arabisch](README_AR.md) | [🇩🇪 Deutsch](README_DE.md)

---

##  Projektidee:

Dieses Projekt bietet eine vollständige Pipeline zur **Verarbeitung, Analyse und Steuerung** basierend auf EMG-Signalen (Elektromyographie) mit MATLAB.

Es besteht aus drei Hauptphasen:

1. **Filterung des EMG-Signals**, um Rauschen zu entfernen.  
2. **Merkmalextraktion und Diagnose** von Muskelzuständen.  
3. **Muskelgesteuerte Steuerung**, bei der je nach Aktivität ein Bild (Hand offen/geschlossen) angezeigt wird.

> ⚠️ Die verwendeten EMG-Signale wurden **manuell in MATLAB simuliert** und stammen nicht aus echter Hardware.

---

##  Phase 1: Generierung und Filterung des EMG-Signals

###  Ziel:

* Simulation eines verrauschten EMG-Signals mit Frequenzanteilen im Bereich 20–450 Hz.  
* Filterung des Signals mit einem Butterworth-Bandpassfilter.

###  MATLAB-Code:

```matlab
Fs = 1000; % Abtastfrequenz
t = 0:1/Fs:5; % 5 Sekunden

% Generierung eines synthetischen EMG-Signals
emg_clean = 0.5 * sin(2*pi*60*t) + 0.3 * sin(2*pi*150*t);
noise = 0.2 * randn(size(t));
emg_raw = emg_clean + noise;

% Plot des Rohsignals
figure;
plot(t, emg_raw);
title('Rohes EMG-Signal');
xlabel('Zeit (s)'); ylabel('Amplitude');

% Bandpassfilterung (20–450 Hz)
[b, a] = butter(4, [20 450]/(Fs/2), 'bandpass');
emg_filtered = filtfilt(b, a, emg_raw);

% Plot des gefilterten Signals
figure;
plot(t, emg_filtered);
title('Gefiltertes EMG-Signal');
xlabel('Zeit (s)'); ylabel('Amplitude');
```

---

##  Phase 2: Diagnose (Klassifikation)

###  Ziel:

Extraktion signifikanter Merkmale aus dem gefilterten Signal und Klassifikation in eine der folgenden Kategorien:

- **Gesund**  
- **Myopathie**  
- **Neuropathie**

###  Extrahierte Merkmale:

- **RMS** (Root Mean Square / Effektivwert)  
- **MAV** (Mean Absolute Value / Durchschnittlicher Absolutwert)  
- **WL** (Waveform Length / Wellenformlänge)

###  Merkmalsextraktion:

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
title('Extrahierte EMG-Merkmale');
xlabel('Zeit (s)'); ylabel('Merkmalswert');
```

---

###  Klassifikation der EMG-Zustände:

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

% Klassifikator trainieren
X = features; Y = class_labels;
model = fitcecoc(X, Y);

% Test der Vorhersage
predicted = predict(model, X(1:5,:));
disp('Vorhergesagte Klassen für die ersten 5 Fenster:');
disp(predicted);
```

---

##  Phase 3: Visuelle Steuerung basierend auf Muskelaktivität

###  Ziel:

Anzeigen eines Bildes (offene/geschlossene Hand), abhängig vom MAV-Wert jedes Signalabschnitts.

###  Benötigte Bilder:

- `hand_open.png`  ← offene Hand  
- `hand_closed.png`  ← geschlossene Hand  

> Diese Bilder müssen sich im selben Ordner wie das Skript befinden.

###  Steuerungscode:

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
        title_txt = '🔓 Muskel aktiv → Hand offen';
    else
        img = imread('hand_closed.png');
        title_txt = '🔒 Muskel inaktiv → Hand geschlossen';
    end

    imshow(img);
    title(title_txt, 'FontSize', 14);
    pause(0.1);
end
```
---

##  Beispielhafte Steuerungsbilder

Hier sind die Referenzbilder, die als visuelle Rückmeldung für die Muskelaktivität verwendet werden:

### 🔓 Hand offen:
![Hand offen](hand_open.png)

### 🔒 Hand geschlossen:
![Hand geschlossen](hand_closed.png)

> ⚠️ Stelle sicher, dass sich die Bilder `hand_open.png` und `hand_closed.png` im **gleichen Verzeichnis** wie die Datei `README_DE.md` befinden.

---

##  Zusammenfassung:

-  Das EMG-Signal wird manuell mit `sin` und `randn` in MATLAB erzeugt.  
-  Gefiltert mit einem Bandpassfilter (20–450 Hz).  
-  Merkmale (RMS, MAV, WL) werden extrahiert und zur Klassifikation genutzt.  
-  Ein einfaches visuelles Steuersystem wechselt je nach Muskelaktivität das Bild.

>  **Dieses Projekt wurde vollständig von der biomedizinischen Ingenieurin Wasan Qusay Hasan  mit MATLAB Online entwickelt und dokumentiert.**  
> Es dient als Grundlage für Erweiterungen (GUI, Echtzeit, Arduino) oder als akademisches Projekt (z. B. Bachelorarbeit, Trainingsmappe).
