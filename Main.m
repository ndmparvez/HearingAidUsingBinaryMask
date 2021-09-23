clc;
close all;
[mSpeech,Fs] = audioread("MaleSpeech-16-4-mono-20secs.wav");
sound(mSpeech,Fs)
%sound(mSpeech,Fs)
[nois] = awgn(mSpeech,10,'measured');
%sound(fSpeech,Fs)
mSpeech = mSpeech/norm(mSpeech);
nois = nois/norm(nois);
ampAdj = max(abs([mSpeech;nois]));
mSpeech = mSpeech/ampAdj;
nois = nois/ampAdj;
mix = mSpeech + nois;
mix = mix ./ max(abs(mix));
t = (0:numel(mix)-1)*(1/Fs);
figure(1)
subplot(3,1,1)
plot(t,mSpeech)
title("Male Speech")
grid on
subplot(3,1,2)
plot(t,nois)
title("Noise")
grid on
subplot(3,1,3)
plot(t,mix)
title("Speech Mix")
xlabel("Time (s)")
grid on
%sound(mix,Fs)
WindowLength = 128;
FFTLength = 128;
OverlapLength = 96;
win = hann(WindowLength,"periodic");
figure(2)
subplot(3,1,1)
stft(mSpeech, Fs, 'Window', win,'OverlapLength',OverlapLength,'FFTLength', FFTLength);%,'FrequencyRange','onesided');
title("Male Speech")
subplot(3,1,2)
stft(nois, Fs, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', FFTLength);%, 'FrequencyRange', 'onesided');
title("Noise")
subplot(3,1,3)
stft(mix, Fs, 'Window', win, 'OverlapLength', OverlapLength,'FFTLength', FFTLength);%, 'FrequencyRange', 'onesided');
title("Mix Speech")
P_M = stft(mSpeech, 'Window', win, 'OverlapLength',OverlapLength,'FFTLength', FFTLength);%, 'FrequencyRange', 'onesided');
P_N = stft(nois, 'Window', win, 'OverlapLength', OverlapLength,'FFTLength', FFTLength);%, 'FrequencyRange', 'onesided');
[P_mix,F] = stft(mix, 'Window', win, 'OverlapLength', OverlapLength,'FFTLength', FFTLength);%, 'FrequencyRange');%, 'onesided');
binaryMask = abs(P_M) >= abs(P_N);
figure(3)
plotMasking(binaryMask, WindowLength - OverlapLength, F, Fs)
P_M_Hard = P_mix .* binaryMask;
P_F_Hard = P_mix .* (1-binaryMask);
mSpeech_Hard = istft(P_M_Hard , 'Window', win, 'OverlapLength',OverlapLength,'FFTLength', FFTLength);%, 'FrequencyRange,'onesided');
Noise_Hard = istft(P_F_Hard , 'Window', win, 'OverlapLength',OverlapLength,'FFTLength', FFTLength);%, 'FrequencyRange','onesided');
figure(4)
subplot(2,2,1)
plot(t,mSpeech)
axis([t(1) t(end) -1 1])
title("Original Male Speech")
grid on
subplot(2,2,3)
plot(t,mSpeech_Hard)
axis([t(1) t(end) -1 1])
xlabel("Time (s)")
title("Estimated Male Speech")
grid on
subplot(2,2,2)
plot(t,nois)
axis([t(1) t(end) -1 1])
title("Original Noise Speech")
grid on
subplot(2,2,4)
plot(t,Noise_Hard)
axis([t(1) t(end) -1 1])
title("Noise")
xlabel("Time (s)")
grid on
%sound(mSpeech_Hard,Fs)
sound(Noise_Hard,Fs)
