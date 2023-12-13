function [percent_cov_CDMA] = CDMA_Network(handles)
%Default values:
%INPUTS
% % Selection of Transmitter
% Transmitt_stations=[5 19];
% % Tx Power -> femtocell 20dBm = -10dB
% Transmitt_Powers=[-10 -10];
% % Gain -> femtocell 2dBi
% Gains=[2 2];
% 
% Tx_Power_User=[-19];  %PROSOXI to Tx Power ston User einai mikrotero apo Transmitt_Powers
% 
% w=3.84.*10.^6;     %chip rate CDMA
% Rb=64.*10.^3;       %bit rate
% Noise_Fig=10;
% Orthogonality_Factor=0.6;
% Eb_I_Threshold=6;    %dB
% T=300;             % Celsius -> Kelvin: K=20+273 
%%%%%%%%%%%%%%%%%%%%%%%%%%
Transmitt_stations = handles.TxIDS;
Transmitt_Powers = handles.TxPows;
Gains = handles.TxGains;

Noise_Fig = handles.NoiseFig;
T = handles.NoiseTemp;
label = handles.figures_title;

w = handles.chirp;
Rb = handles.bitrate;
Orthogonality_Factor = handles.Orthogonality_Factor;
Eb_I_Threshold = handles.Eb_I_Threshold;
Tx_Power_User = handles.Tx_Power_User;

Txs = handles.TxIDS;

Transmit_Power_Aware=handles.Transmit_Power_Aware;

[X,Y,Z]=meshgrid(0:0.25:45,0:0.25:45,1.5:0.25:1.5);

%-----------------------------------


% Rx Sensitivity -> femtocell -95dBm = -125dB
% Thermal Noise
k= 1.38.*10.^-23;  % Boltzmann 1.38*10^-23

Pn_CDMA=(k.*T.*w.*Noise_Fig);


Rx_Sensitivity=10.*log10(Pn_CDMA);
% Bit Rate


% Chip Rate
Rc=w;

% Received Field
Carrier=Transmitt_stations;
Carrier_Tx_Power=Transmitt_Powers(Transmitt_stations==Carrier);
Carrier_Gain=Gains(Transmitt_stations==Carrier);

Total_Wanted_CDMA=zeros(size(X));
for ii=1:max(size(Carrier))
    Txx=Carrier(ii);
    Tx_P=Carrier_Tx_Power(ii);
    Tx_G=Carrier_Gain(ii);
    count=1;

  for i=1:size(Y,2)    
      for q=1:size(X,1) 

          Wanted_Power_CDMA(q,i,ii)=Transmit_Power_Aware(Txx).ReceivePower(count).PathLoss+Carrier_Tx_Power(ii)+Carrier_Gain(ii);
          
          count=count+1;      
      end  
  end

Total_Wanted_CDMA=10.^(Wanted_Power_CDMA(:,:,ii)./10)+Total_Wanted_CDMA;
end

pedio=10.*log10(abs(Total_Wanted_CDMA));



Total=zeros(size(X));
for i=1:size(Y,2)
    for q=1:size(X,1)
        
         for ii=1:max(size(Carrier))
                      
             received(ii,:)=Wanted_Power_CDMA(q,i,ii);
             Total(q,i)=10.^(received(ii,:)./10)+Total(q,i);
         end
         
      
          [~,Tx_id]=sort(received,'descend');
             best_server(q,i)=Tx_id(1);
       
          
    end
end


total_interference_CDMA=zeros(size(X));

for i=1:size(Y,2)    

    for q=1:size(X,1)
        
        for jj=1:max(size(Transmitt_stations))
            
            if jj==best_server(q,i)
                continue
            else
                
                total_interference_CDMA(q,i)=total_interference_CDMA(q,i)+10.^(Wanted_Power_CDMA(q,i,jj)./10);
                
            end
            
        end
                
        
%         Eb_No_CDMA(q,i)=10.^((Wanted_Power_CDMA(q,i,best_server(q,i))+(Tx_Power_User-Transmitt_Powers(best_server(q,i))))./10).*Rc./(Rb.*((1-Orthogonality_Factor).*10.^(Wanted_Power_CDMA(q,i,best_server(q,i))./10)+total_interference_CDMA(q,i)+Pn_CDMA)); 
        
%         Eb_No_CDMA(q,i)=Total_Wanted_CDMA(q,i).*10.^((Tx_Power_User-Transmitt_Powers(best_server(q,i)))./10).*Rc./(Rb.*((1-Orthogonality_Factor).*10.^(Wanted_Power_CDMA(q,i,best_server(q,i))./10)+total_interference_CDMA(q,i)+Pn_CDMA)); 
        
        Eb_No_CDMA(q,i)=Total_Wanted_CDMA(q,i).*10.^((Tx_Power_User-Transmitt_Powers(best_server(q,i)))./10).*Rc./(Rb.*((1-Orthogonality_Factor).*10.^(Wanted_Power_CDMA(q,i,best_server(q,i))./10)+total_interference_CDMA(q,i)+Pn_CDMA)); 
        
    end
    
end


rr=10.*log10(abs(Eb_No_CDMA));
rr(rr<=Eb_I_Threshold)=0;
rr(rr>Eb_I_Threshold)=1;
coverage=rr;

%OUPUT Values
percent_cov_CDMA=max(size(find(rr==1)))./(size(rr,1).*size(rr,2)).*100;
%-------------------------------------

%---------PLOTS--------------------
figure('Name', label);
axis1 = gca();
view(axis1, 3);
box(axis1, 'off');
surf(axis1, X,Y,Z,coverage);
shading(axis1, 'interp');
hold on;
    ProCreateCity(axis1, 19);
%h=findobj('Type','Surf');
%%hh=findobj('Type','Patch');
%alpha(h,1);
%alpha(hh,0.5);
axis(axis1, "equal", "tight");
xlabel(axis1, 'x-axis');
ylabel(axis1, 'y-axis');
colormap(axis1, "jet");
title(axis1, 'Coverage plot. Red color denotes coverage.');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis1, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end

figure('Name', label);
axis2 = gca();
view(axis2, 3);
box(axis2, 'off');
surf(axis2, X,Y,Z,10.*log10(abs(Eb_No_CDMA)));
shading(axis2, 'interp');
hold on;
    ProCreateCity(axis2, 19);
%h=findobj('Type','Surf');
%%hh=findobj('Type','Patch');
%alpha(h,1);
%alpha(hh,0.5);
axis(axis2, "equal", "tight");
xlabel(axis2, 'x-axis');
ylabel(axis2, 'y-axis');
colormap(axis2, "jet");
c = colorbar(axis2, 'ytick', 0:2:12);
set(c, 'position', [0.87, 0.1, 0.05, 0.8]);
title(axis2, 'log-scale (dB) Eb/No ratio for CDMA.');

hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis2, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end
caxis(axis2, [0 12]);
%---------PLOTS--------------------