clc;
close all;
clear variables;

set(groot,'defaulttextinterpreter','latex');  
%% Vremenski domen
Fs = 2000; % Hz
t = (0:8191)/Fs; % s

%% Frekvencijski domen
N = 2^11;

my_phase = 200;

freqs = 1:100;

for i = 1:length(freqs)
    y = 0 + 1000 * cos(2*pi*freqs(i) * t(1:2048) + my_phase * pi / 180);

%     y = y .* flattopwin(length(y))';
    [absY1, phaseY1] = my_fft(y, N);

    [maxval, index] = max(absY1);
    measured_phases(i) = phaseY1(index) / pi * 180;
    
%     if measured_phases(i) < 0
%        measured_phases(i) = measured_phases(i) + 180; 
%     end
end

figure;
stem(freqs, measured_phases)
title("Faze")
xlabel("f [Hz]")
ylabel("$arg(X(j2\pi f))$ [rad]")
hold on;
yline(my_phase, 'r')

fi_array = zeros(length(freqs), 1);
for i = 1:length(freqs)
    % viktor
%     fi0 = measured_phases(i) + 4.3*(- freqs(i));
%     fi0 = mod(fi0, 360);

    % aleksa
    fi0 = phase_correct(measured_phases(i), freqs(i));
    fi_array(i) = fi0;
end

figure;
stem(freqs, fi_array)
title("Procena Viktor")
xlabel("f [Hz]")
ylabel("$\phi$ [deg]")
yline(my_phase, 'r')

function fi_out = phase_correct(fi_in, freq_in)

    k = 0;
    fi_out = fi_in - 4.3 * freq_in + k *180;
    
    if fi_out < -180
        increment_val = 1;
    else
        increment_val = -1;
    end
    while (fi_out < -180 || fi_out > 180)
        k = k+increment_val;
        fi_out = fi_in - 4.3 * freq_in + k * 180;
    end
end


function [absX1, phaseX1] = my_fft(x, N)

    X = fft(x, N);
    dc = X(1);
    desno = X(2:N/2 + 1); % jedan odbirak vise na kraju od levo
    levo = X(N/2 + 2:N);
    X = [levo, dc, desno];

    absX1 = abs([dc, desno] / length(x));
    absX1(2:end) = absX1(2:end) * 2;

    phaseX1 = angle([dc, desno]);

end