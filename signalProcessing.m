function F = signalProcessing(BufData,bk)

fs=16000;

a = 1;
buf_filt   = filtfilt(bk,a,BufData);

Nsamples  = length(BufData);
Nfft      = Nsamples;
k         = 0:1:Nfft-1;
f         = (k/Nfft)*fs;
f         = f(1:Nfft/2);

yi1       = fft(buf_filt,Nfft);
yi1       = yi1(1:Nfft/2);
yi1       = (1*abs(yi1));
yi1       = yi1/max(yi1);
Y1=yi1';


freq_limS=4000;
freq_limI=1000;

inc  = 50;
fini = freq_limI:inc:freq_limS-inc;
ffin = fini + inc;
fcen = fini + inc/2;

% Numero de rangos de frecuencias
Nfr  = length(fini);

% Extracción de características

    for i=1:Nfr
        fl           = fini(i);
        fh           = ffin(i);
        indx         = (f>=fl & f<fh);
        
        % v son los promedios por rangos de frecuencia de Y
        F(:,i) =  median(Y1(:,indx),2);
    end
    
end