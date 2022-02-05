function General_Parameters_Net(handles)
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
% B=10.*10.^6;       % Bandwidth
% CINR_threshold=5;
%%%%%%%%%%%%%%%%%%%%%%%%%%
Transmitt_stations = handles.TxIDS;
Transmitt_Powers = handles.TxPows;
Gains = handles.TxGains;

Noise_Fig = handles.NoiseFig;
T = handles.NoiseTemp;
B = handles.BW;
CINR_threshold = handles.SINRthresh;
label = handles.figures_title;

Txs = handles.TxIDS;

Transmit_Power_Aware = handles.Transmit_Power_Aware;
[X,Y,Z] = meshgrid(0:0.25:45,0:0.25:45,1.5:0.25:1.5);


% Rx Sensitivity -> femtocell -95dBm = -125dB
% Thermal Noise
k= 1.38.*10.^-23;  % Boltzmann 1.38*10^-23

Pn=(k.*T.*B.*Noise_Fig);


Rx_Sensitivity=10.*log10(Pn);

% Received Field
Carrier=Transmitt_stations;
Carrier_Tx_Power=Transmitt_Powers(Transmitt_stations==Carrier);
Carrier_Gain=Gains(Transmitt_stations==Carrier);

Total_Wanted=zeros(size(X));

for ii=1:max(size(Carrier))
    Txx=Carrier(ii);
    Tx_P=Carrier_Tx_Power(ii);
    Tx_G=Carrier_Gain(ii);
    count=1;

  for i=1:size(Y,2)    
      for q=1:size(X,1) 

          Wanted_Power(q,i,ii)=Transmit_Power_Aware(Txx).ReceivePower(count).PathLoss+Carrier_Tx_Power(ii)+Carrier_Gain(ii);
          
          count=count+1;      
      end  
  end

Total_Wanted=10.^(Wanted_Power(:,:,ii)./10)+Total_Wanted;

end

pedio=10.*log10(abs(Total_Wanted));


%----For plotting only----------
% Best Server CDMA
Total=zeros(size(X));
for i=1:size(Y,2)
    for q=1:size(X,1)
        
         for ii=1:max(size(Carrier))
                      
             received(ii,:)=Wanted_Power(q,i,ii);
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
                      
             received(ii,:)=Wanted_Power(q,i,ii);
             Total(q,i)=10.^(received(ii,:)./10)+Total(q,i);
         end
         
      
          [~,Tx_id]=sort(received,'descend');
             best_server(q,i)=Tx_id(1);
       
          
    end
end


total_interference=zeros(size(X));

for i=1:size(Y,2)    

    for q=1:size(X,1)
        
        for jj=1:max(size(Transmitt_stations))
            
            if jj==best_server(q,i)
                continue
            else
                
                total_interference(q,i)=total_interference(q,i)+10.^(Wanted_Power(q,i,jj)./10);
                
            end
            
        end
                
        CINR(q,i)=10.^(Wanted_Power(q,i,best_server(q,i))./10)./(total_interference(q,i)+Pn); 
        
    end
    
end



% Coverage
rr=10.*log10(abs(CINR));
rr(rr<=CINR_threshold)=0;
rr(rr>CINR_threshold)=1;
coverage=rr;

%---------PLOTS--------------------
figure('Name', label);
axis1 = gca();
view(axis1, 3);
box(axis1, 'off');
surf(axis1, X,Y,Z,pedio);
shading(axis1, 'interp');
hold on;
  ProCreateCity(axis1, 19);
%h=findobj('Type','Surf');
%hh=findobj('Type','Patch');
%alpha(h,1);
%alpha(hh,0.5);
axis(axis1, "equal", "tight");
xlabel(axis1, 'x-axis');
ylabel(axis1, 'y-axis');
colormap(axis1, "jet");
c = colorbar(axis1, 'ytick', -140:20:-20);
set(c, 'position', [0.87, 0.1, 0.05, 0.8]);
title(axis1, 'Received Field.');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis1, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end
caxis(axis1, [-140 -20]);    

figure('Name', label);
axis2 = gca();
view(axis2, 3);
box(axis2, 'off');
surf(axis2, X,Y,Z,coverage);
shading(axis2, 'interp');
hold on;
    ProCreateCity(axis2, 19);
%h=findobj('Type','Surf');
%%hh=findobj('Type','Patch');
%alpha(h,1)
%alpha(hh,0.5)
axis(axis2, "equal", "tight");
xlabel(axis2, 'x-axis');
ylabel(axis2, 'y-axis');
colormap(axis2, "jet");
title(axis2, 'Coverage plot (Dark red denotes coverage).');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis2, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end

figure('Name', label);
axis3 = gca();
view(axis3, 3);
box(axis3, 'off');
surf(axis3, X,Y,Z,10.*log10(CINR));
shading(axis3, 'interp');
hold on;
    ProCreateCity(axis3, 19);
%h=findobj('Type','Surf');
%%hh=findobj('Type','Patch');
%alpha(h,1)
%alpha(hh,0.1)
axis(axis3, "equal", "tight");
xlabel(axis3,'x-axis');
ylabel(axis3,'y-axis');
colormap(axis3,"jet");
c = colorbar(axis3,'ytick', -10:5:40);
set(c, 'position', [0.87, 0.1, 0.05, 0.8]);
title(axis3,'CINR plot.');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis3,handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end
caxis(axis3, [-10 40]);

figure('Name', label);
axis4 = gca();
view(axis4, 3);
box(axis4, 'off');
surf(axis4, X,Y,Z,best_server2);
shading(axis4, 'interp');
hold on;
  ProCreateCity(axis4, 19);
%h=findobj('Type','Surf');
%%hh=findobj('Type','Patch');
%alpha(h,1)
%alpha(hh,0.5)
axis(axis4, "equal", "tight");
xlabel(axis4, 'x-axis');
ylabel(axis4, 'y-axis');
colormap(axis4, "jet");
title(axis4, 'Best server plot.');
hold on;
for i=1:length(Txs)
    tx_id=Txs(i);
    stem3(axis4, handles.Tx_Pos(tx_id,2),handles.Tx_Pos(tx_id,3),handles.Tx_Pos(tx_id,4)+1,'g');
end

%---------PLOTS--------------------


