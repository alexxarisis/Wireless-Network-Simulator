function [percent_cover_OFDM, percent_qpsk, percent_qam16, percent_qam64] = OFDM_Network(handles)
%Default values:
% %INPUTS
% % Selection of Transmitter
% Transmitt_stations=[5 19];
% % Tx Power -> femtocell 20dBm = -10dB
% Transmitt_Powers=[-10 -10];
% % Gain -> femtocell 2dBi
% Gains=[2 2];
% B=10.*10.^6;       % femtocell 10 MHz
% 
% N=250;     %number of Subcarriers per user
% Noise_Fig=10;
% 
% Probability=0.3; %probability other base station transmitting on same subchannels
% N_tot=1000;  %total NUmber of Subcarriers
% % Thermal Noise
% T=300;             % Celsius -> Kelvin: K=20+273 
% Bw_sub=B./N_tot; %assume 1000 subcarriers and 10MHz BW
% F_sampl=11.*10.^6; % 11 MHz
% % Rx Sensitivity -> femtocell -95dBm = -125dB
%%%%%%%%%%%%%%%%%%%%%%%%%%
Transmitt_stations = handles.TxIDS;
Transmitt_Powers = handles.TxPows;
Gains = handles.TxGains;

Noise_Fig = handles.NoiseFig;
T = handles.NoiseTemp;
B = handles.BW;
label = handles.figures_title;

N = handles.NofSubcPerUser;
Probability = handles.Probability;
N_tot = handles.NofSubcTotal;
F_sampl = handles.F_sampl;

Txs = handles.TxIDS;

Transmit_Power_Aware=handles.Transmit_Power_Aware;

[X,Y,Z]=meshgrid(0:0.25:45,0:0.25:45,1.5:0.25:1.5);
Bw_sub=B./N_tot;
k= 1.38.*10.^-23;  % Boltzmann 1.38*10^-23
Pn_OFDM=k.*T.*F_sampl.*N./N_tot.*Noise_Fig+k.*T.*Bw_sub.*Noise_Fig;


% Received Field
Carrier=Transmitt_stations;
Carrier_Tx_Power=Transmitt_Powers(Transmitt_stations==Carrier);
Carrier_Gain=Gains(Transmitt_stations==Carrier);

Total_Wanted_CDMA=zeros(size(X));
Total_Wanted_OFDM=zeros(size(X));
for ii=1:max(size(Carrier))
    Txx=Carrier(ii);
    Tx_P=Carrier_Tx_Power(ii);
    Tx_G=Carrier_Gain(ii);
    count=1;

  for i=1:size(Y,2)    
      for q=1:size(X,1)

          Wanted_Power_CDMA(q,i,ii)=Transmit_Power_Aware(Txx).ReceivePower(count).PathLoss+Carrier_Tx_Power(ii)+Carrier_Gain(ii);
          Wanted_Power_OFDM(q,i,ii)=Transmit_Power_Aware(Txx).ReceivePower(count).PathLoss+Carrier_Tx_Power(ii)-10.*log10(N_tot)+Carrier_Gain(ii);
          
          count=count+1;     
      end
  end

Total_Wanted_CDMA=10.^(Wanted_Power_CDMA(:,:,ii)./10)+Total_Wanted_CDMA;
Total_Wanted_OFDM=10.^(Wanted_Power_OFDM(:,:,ii)./10)+Total_Wanted_OFDM;

end
pedio=10.*log10(abs(Total_Wanted_CDMA));
pedio_OFDM=10.*log10(abs(Total_Wanted_OFDM));


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


total_interference_OFDM=zeros(size(X));
for i=1:size(Y,2)    

    for q=1:size(X,1)
        
        for jj=1:max(size(Transmitt_stations))
            
            if jj==best_server(q,i)
                continue
            else
                
                total_interference_OFDM(q,i)= total_interference_OFDM(q,i)+10.^(Wanted_Power_OFDM(q,i,jj)./10);
                
            end
            
        end
                
        
    end
    
end

##% 191 sec
##for i=1:size(Y,2)    
##    for q=1:size(X,1)
##        par=0;
##        for ii=1:N;
##           par=par+log2(1+(10.^(Wanted_Power_OFDM(q,i,best_server(q,i))./10)./(total_interference_OFDM(q,i).*Probability+Pn_OFDM)));
##        end
##        gama_nn(q,i)=2.^((1/N).*par)-1;
##    end
##end


##% 148 sec
##% this saves approx. 40 sec
##gama_nn = zeros(size(Y,2), size(X,1));
##for i=1:size(Y,2)    
##    for q=1:size(X,1)
##        par=0;
##        for ii=1:N;
##           par=par+log2(1+(10.^(Wanted_Power_OFDM(q,i,best_server(q,i))./10)./(total_interference_OFDM(q,i).*Probability+Pn_OFDM)));
##        end
##        gama_nn(q,i)=2.^((1/N).*par)-1;
##    end
##end

% 0.57 sec
##gama_nn = zeros(size(Y,2), size(X,1));
##for i=1:size(Y,2)    
##    for q=1:size(X,1)
##        par=N*log2(1+(10.^(Wanted_Power_OFDM(q,i,best_server(q,i))./10)./(total_interference_OFDM(q,i).*Probability+Pn_OFDM)));
##        gama_nn(q,i)=2.^((1/N).*par)-1;
##    end
##end

% 0.56 sec
gama_nn = zeros(size(Y,2), size(X,1));
for i=1:size(Y,2)    
    for q=1:size(X,1)
        par=log2(1+(10.^(Wanted_Power_OFDM(q,i,best_server(q,i))./10)./(total_interference_OFDM(q,i).*Probability+Pn_OFDM)));
        gama_nn(q,i)=2.^par-1;
    end
end

SNIR_eff=10.*log10(abs(gama_nn));
% SNR - Modulation
SNIR_eff(SNIR_eff==inf)=-120;
Modulation=SNIR_eff;
Modulation(SNIR_eff<=2.88)=0;                            %'NULL'  
Modulation(SNIR_eff>2.88 & SNIR_eff<=10.7)=1;       %'QPSK' 
Modulation(SNIR_eff>10.7 & SNIR_eff<=16)=2;       %'16QAM'  
Modulation(SNIR_eff>16)=3;                             %'64QAM'

cover_ofdm=max(size(find(Modulation>0)))./(size(Modulation,1).*size(Modulation,2)).*100;


%OUTPUT VALUES
percent_cover_OFDM=cover_ofdm;

percent_qpsk=max(size(find(Modulation==1)))./(size(Modulation,1).*size(Modulation,2)).*100;

percent_qam16=max(size(find(Modulation==2)))./(size(Modulation,1).*size(Modulation,2)).*100;

percent_qam64=max(size(find(Modulation==3)))./(size(Modulation,1).*size(Modulation,2)).*100;
%---------------------------

%---------PLOTS--------------------
figure('Name', label);
axis1 = gca();
view(axis1, 3);
box(axis1, 'off');
surf(axis1, X,Y,Z,SNIR_eff);
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
c = colorbar(axis1, 'ytick', 0:5:40);
set(c, 'position', [0.87, 0.1, 0.05, 0.8]);
title(axis1, 'SNIR plot.');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis1, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end
caxis(axis1, [0 40]);    

figure('Name', label);
axis2 = gca();
view(axis2, 3);
box(axis2, 'off');
surf(axis2, X,Y,Z,Modulation);
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
c = colorbar(axis2);
set(c, 'ytickLabel', {'0: No coverage','','1: QPSK','','2: 16-QAM','','3: 64-QAM'});
set(c, 'position', [0.83, 0.1, 0.05, 0.8]);
title(axis2, 'OFDM Modulation preference.');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis2, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end
%---------PLOTS--------------------

