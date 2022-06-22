%% INICIALIZAR
clearvars
close
clc
%% CARGAR PARAMETROS FILTRO Y MODELO

% Filters
bk=load("CoeficientesFiltros.mat","b");
bk=bk.b;

modelo=load("Modelo.mat","modelo");
bn=modelo.modelo.b;
b0=modelo.modelo.b0;

%% PARAMETROS BUFFER

% Frecuencia de muestreo
fs           = 16000;

% Se define la ventana de captación de audio "inmediata"
WinDura      = 0.05;
WinSamp      = ceil(WinDura*fs);
WinTime      = (0:1:WinSamp-1)/fs;
WinData      = zeros(WinSamp,1);

% MyADR es el objeto que recibe la señal
MyADR        = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',WinSamp);

% Inicializar el buffer
BufDura      = 1;                       % Buffer dura 1 segundo
BufSamp      = ceil(BufDura*fs);        % Duración en muestras
BufTime      = (0:1:BufSamp-1)/fs;
BufData      = zeros(BufSamp,1);        % Aqui se van guardando los datos
BF           = dsp.AsyncBuffer(BufSamp);

% Inicializar el buffer con zeros
write(BF, BufData);

% Obtener los datos del buffer
BufData  = peek(BF);

% Actualizar el tiempo de la ventana
WinTime = WinTime+(BufDura-WinDura);


%% GET AND PLOT AUDIO DATA

% Definir un tiempo máximo que corra el programa
Tmax      = 200*BufDura;

% Se empieza con la obtención de datos en un while, usando tic y toc para
% llevar la cuenta del tiempo que el programa ha corrido
tic
while toc < Tmax
    
    % En la ventana se guardan los datos que se reciben inmediatamente
    % (Duration of 'WinDura')
    WinData  = MyADR();
    
    % Se escriben los datos capturados al buffer
    write(BF, WinData);
    
    % Con peek se obtienen los datos del buffer
    BufData  = peek(BF);

    % datos recibidos se mandan a la función signalProcessing que
    % recibe como parametros los datos y los coeficientes del filtro FIR
    % previamente calculados
    F= signalProcessing(BufData,bk);


    chilaquil='';
   

    % Se reciben los datos procesados y se mandan a ClasificationModel(F,b0,bn) 

        z = ClasificationModel(F,b0,bn);
    
     % La función regresa z que según sea positiva o negativa dirá si se
     % detectó la palabra o no

        if z<0
            % Do nothing
            chilaquil='Chilaquil detectado';
        elseif z>0
            chilaquil='Nada';
        end


    % Plot WinData y BufData
    % {
    figure(1), clf, hold on
    plot(BufTime,BufData,'LineWidth',4)
    plot(WinTime,WinData,'LineWidth',1)
    hold off
%  plot(F)
    xlabel('Time (s)'), ylabel('x(t)'),title(chilaquil), box on
   
    set(gca,'YLim',[-1 1])
    % }
end
