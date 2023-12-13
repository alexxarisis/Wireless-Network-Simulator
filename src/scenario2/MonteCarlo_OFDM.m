function MonteCarlo_OFDM(handles)
%ASSUMPTION IS 1 CELL CAN SERVE AT MOST 4 USERS AND NUMBER OF SUBCARRIERS
%PER USER IS 250
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
% Runs=1000;       %montecarlo runs
% maxUsers=10;
% minUsers=2;
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

minUsers = handles.minUsers;
maxUsers = handles.maxUsers;
Runs = handles.Runs;

Transmit_Power_Aware=handles.Transmit_Power_Aware;

[X,Y,~]=meshgrid(0:0.25:45,0:0.25:45,1.5:0.25:1.5);
k= 1.38.*10.^-23;  % Boltzmann 1.38*10^-23
Bw_sub=B./N_tot; %assume 1000 subcarriers and 10MHz BW


Pn_OFDM=k.*T.*F_sampl.*N./N_tot.*Noise_Fig+k.*T.*Bw_sub.*Noise_Fig;

Pn_CDMA=(k.*T.*B.*Noise_Fig);




Rx_Sensitivity=10.*log10(Pn_CDMA);

% Received Field
Carrier=Transmitt_stations;
Carrier_Tx_Power=Transmitt_Powers(Transmitt_stations==Carrier);
Carrier_Gain=Gains(Transmitt_stations==Carrier);

Total_Wanted_CDMA=zeros(size(X));
Total_Wanted_OFDM=zeros(size(X));
for ii=1:max(size(Carrier))
    Txx=Carrier(ii);
    Tx_P=Carrier_Tx_Power(ii); % ??
    Tx_G=Carrier_Gain(ii); % ??
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

%----For plotting only----------
% Best Server CDMA
Total=zeros(size(X));
for i=1:size(Y,2)
    for q=1:size(X,1)
        
         for ii=1:max(size(Carrier))
                      
             received(ii,:)=Wanted_Power_CDMA(q,i,ii);
             Total(q,i)=10.^(received(ii,:)./10)+Total(q,i);
         end
         
       Total_dB(q,i)=10.*log10(abs(Total(q,i)));
 
       if (Total_dB(q,i)<Rx_Sensitivity)
            best_server2(q,i)=0;  
           
       else
          [~,Tx_id]=sort(received,'descend');
             best_server2(q,i)=Tx_id(1);
       end
          
    end
end
%----For plotting only----------


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
total_interference_OFDM=zeros(size(X));
for i=1:size(Y,2)    

    for q=1:size(X,1)
        
        for jj=1:max(size(Transmitt_stations))
            
            if jj==best_server(q,i)
                continue
            else
                
                total_interference_CDMA(q,i)=total_interference_CDMA(q,i)+10.^(Wanted_Power_CDMA(q,i,jj)./10);
                total_interference_OFDM(q,i)= total_interference_OFDM(q,i)+10.^(Wanted_Power_OFDM(q,i,jj)./10);
                
            end
            
        end
                
        
    end
    
end

##% approx 107 secs
##for i=1:size(Y,2)    
##    for q=1:size(X,1)
##        par=0;
##        for ii=1:N;
##            par=par+log2(1+(10.^(Wanted_Power_OFDM(q,i,best_server(q,i))./10)./(total_interference_OFDM(q,i).*Probability+Pn_OFDM)));
##            
##        end
##        gama_nn(q,i)=2.^((1/N).*par)-1;
##    end
##end

% approx 0.5 secs
gama_nn = zeros(size(Y,2), size(X,1));
for i=1:size(Y,2)    
    for q=1:size(X,1)
        par = log2(1+(10.^(Wanted_Power_OFDM(q,i,best_server(q,i))./10)./(total_interference_OFDM(q,i).*Probability+Pn_OFDM)));
        gama_nn(q,i) = 2.^par-1; 
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

for iii=1:Runs

% Users    
%r=randi([1,181],7,2);
r=randi(([1,181]),randi([minUsers,maxUsers]),2);

%-------Computation of Outage probability--------------
for ii=1:max(size(r))
    
Cells(ii,:)=best_server2(r(ii,1),r(ii,2));

Cells_uplink(ii,:)=best_server(r(ii,1),r(ii,2));

Tx_Power_MS(ii,:)=-100-Wanted_Power_CDMA(r(ii,1),r(ii,2),Cells_uplink(ii,:))-Carrier_Tx_Power(Cells_uplink(ii,:))+Carrier_Gain(Cells_uplink(ii,:))+30;
end

Outage_Prob=0;
for jj=1:max(size(Transmitt_stations))
    cell=max(size(find(Cells==jj)));
    if cell-4>0
        
    Outage_Prob=Outage_Prob+abs(cell-4);
    end
end

if isempty(find(Cells==0, 1))==0;
    re=find(Cells==0);
    re=max(size(re));
    Outage_Prob=Outage_Prob+re;
end



Outage_Probability(iii,:)=Outage_Prob./max(size(r)).*100;
Mean_Tx_Power_MS(iii,:)=10.*log10(abs(median(10.^(Tx_Power_MS./10))));
if Mean_Tx_Power_MS(iii,:)>25;
    Mean_Tx_Power_MS(iii,:)=25;
end
%-------Computation of Outage probability--------------

%-------Computation of SINR_Eff--------------
for ii=1:max(size(r))
    
SNIR_effective(ii,:)=SNIR_eff(r(ii,1),r(ii,2));
end
SNIR_effective(SNIR_effective==-inf)=0;
SNIR_effective=10.^(SNIR_effective./10);
SNIR_effective_FInal(iii,:)=10.*log10(median(SNIR_effective));

%-------Computation of SINR_Eff--------------

%-------Modulation--------------

for ii=1:max(size(r))
    
Modulation_Index(ii,:)=Modulation(r(ii,1),r(ii,2));
end
QPSK_mod(iii,:)=max(size(find(Modulation_Index==1)))./max(size(r)).*100;
QAM16_mod(iii,:)=max(size(find(Modulation_Index==2)))./max(size(r)).*100;
QAM64_mod(iii,:)=max(size(find(Modulation_Index==3)))./max(size(r)).*100;

%-------Modulation--------------

clear Modulation_Index
clear SNIR_effective
clear Cells
clear Tx_Power_MS
clear Cells_uplink

end

figure('Name', label);
axis1 = gca();
colormap(axis1, 'jet');
hist(axis1, Outage_Probability,15)
xlim(axis1, [0 100])
% ylim(axis1, [0 1500])
title(axis1, 'Outage probability plot');

figure('Name', label);
axis2 = gca();
colormap(axis2, 'jet');
hist(axis2, SNIR_effective_FInal,15)
% ylim(axis2, [0 1500])
title(axis2, 'SNIR effectiveness plot');

figure('Name', label);
axis3 = gca();
colormap(axis3, 'jet');
hist(axis3, QPSK_mod,15)
xlim(axis3, [0 100])
% ylim(axis3, [0 max(QPSK_mod)+100])
title(axis3, 'QPSK effectiveness plot');

figure('Name', label);
axis4 = gca();
colormap(axis4, 'jet');
hist(axis4, QAM16_mod,15)
xlim(axis4, [0 100])
% ylim(axis4, [0 max(QAM16_mod)+100])
title(axis4, 'QAM16 effectiveness plot');

figure('Name', label);
axis5 = gca();
colormap(axis5, 'jet');
hist(axis5, QAM64_mod,15)
xlim(axis5, [0 100])
% ylim(axis5, [0 max(QAM64_mod)+100])
title(axis5, 'QAM64 effectiveness plot');

figure('Name', label);
axis6 = gca();
colormap(axis6, 'jet');
hist(axis6, Mean_Tx_Power_MS,15)
title(axis6, 'Mean Tx Power plot');


%percent_nocover
%percent_QPSK
%percent_QAM_16
%percent_QAM_64
%mesos_dB