clc;
close all;
clear variables;

set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
%% Parametri
Fs = 2000; % Hz
f = 50; % Hz
A = 1000;
DC = 1;
epsilon = 10;
w = 2*pi*f;
N = 2048;
%% Modifikovani integrator
s = tf('s');
G = 1/(s + epsilon);
W = 1/s;

Gz = c2d(G, 1/Fs, 'tustin');
zpk(Gz)
[num,den] = tfdata(Gz);
Gz = filt(num, den ,1/Fs);
zpk(Gz)

%% Bodeovi dijagrami
figure;
margin(W)
title("Idealni integrator")

figure;
margin(G)
title("Modifikovani integrator")

figure;
margin(Gz)
title("Diskretni modifikovani integrator")

freq_rest_at_w = freqresp(G, w);
gain_at_w = abs(freq_rest_at_w);

%% Signal
t = (0:2047) / Fs;

x = A*cos(2*pi*f * t); %+ 2000 * cos(2*pi*f/2 *t + pi/3);

[y_mod_integ_DC, t] = lsim(Gz, x + DC, t);
[y_integ_DC, t] = lsim(W, x + DC, t);
[y_integ, t] = lsim(W, x, t);

%% Idealni integrator
figure;
sgtitle("Idealna integracija")

subplot(211)
plot(t, x);
xlabel("t [s]")
ylabel("signal [unit]")
title("Ulaz")

subplot(212)
plot(t, y_integ);
xlabel("t [s]")
ylabel("signal [unit]")
title("Izlaz")

%% Idealan sa DC ofsetom
figure;
sgtitle("Idealna integracija sa DC ofsetom")

subplot(211)
plot(t, x);
xlabel("t [s]")
ylabel("signal [unit]")
title("Ulaz")

subplot(212)
plot(t, y_integ_DC);
xlabel("t [s]")
ylabel("signal [unit]")
title("Izlaz")

%% Sa epsilon
figure;
plot(t, y_integ, t, y_mod_integ_DC)
title("Integracija sa modifikacijom - poredjenje")
xlabel("t [s]")
ylabel("signal [unit]")

start_index = round(length(y_mod_integ_DC) * 0.30);
xline(t(start_index), 'LineWidth', 2, 'Color', 'g')

legend("idealno", "sa modifikacijom", "granica")

%% Skidanje DC/epsilon vrednosti

t_trunc = t(start_index:end);
y_integ_trunc = y_integ(start_index:end);
y_mod_integ_DC_trunc = y_mod_integ_DC(start_index:end);

m = mean(y_mod_integ_DC_trunc);

figure;
plot(t_trunc, y_integ_trunc, t_trunc, y_mod_integ_DC_trunc - m)
title("Integracija sa modifikacijom i skinutim DC/epsilon - poredjenje")
xlabel("t [s]")
ylabel("signal [unit]")

legend("idealno", "sa modifikacijom")

%% Različte učestanosti

freqs = [10, 50, 100];

num_plots = 3;
figure;
sgtitle("Poredjenje rezultata za razlicite ucestanosti")
for i = 1:num_plots
    x = A*cos(2*pi*freqs(i) * t);
    
    [y_ideal, ~] = obrada_signala(x, t, W);
    [y, t_trunc] = obrada_signala(x, t, Gz);
    
    subplot(num_plots, 1, i)
    plot(t_trunc, y_ideal, t_trunc, y)
    title("f = " + freqs(i) + " Hz")
    xlabel("t [s]")
    ylabel("signal [unit]")
    legend("idealno", "sa modifikacijom")

end

%% Prolaz kroz sve frekvencije
freqs = 20:0.1:100;
skg = zeros(length(freqs), 1);
for i = 1:length(freqs)
    x = A*cos(2*pi*freqs(i) * t);
    
    [y_ideal, ~] = obrada_signala(x, t, W);
    [y, ~] = obrada_signala(x, t, Gz);
    
    skg(i) = sum((y - y_ideal).^2);
end

figure;
plot(freqs, skg/length(y))
xlabel("f [Hz]")
ylabel("error")
title("Srednje kvadratna greska")

close all;
%% Funkcija

function [out, t_trunc] = obrada_signala(x, t, Gz)
    [y, ~] = lsim(Gz, x, t);
    
    start_index = round(length(y) * 0.30);
    y_trunc = y(start_index:end);
    t_trunc = t(start_index:end);
    m = mean(y_trunc);
    
    out = y_trunc - m;
    
    
end