function [k_Rice, RMS_T, TT_N,PP_N]=Plot_Rays_PDP_Single_Point(handles)
################
Number = handles.interactions;
rx1 = handles.rx_single;
label = handles.figures_title;

###############

%inputs default
%Number=5;
%rx=[14.5 25 1.5]
Ray_PDP=handles.Ray_PDP;
ReceiveSphere=handles.ReceiveSphere;
[X,Y,Z]=meshgrid(0:0.25:45,0:0.25:45,1.5:0.25:1.5);

%INPUTS
%insert the dimensions of the receiver position. Mporeis na
%xrisimopoieiseis tin entoli curf_in

dec=rx1-floor(rx1);
rx1=floor(rx1);
rvals=[0 0.25 0.5 0.75 1];
for i=1:length(dec)
    T=abs(rvals-dec(i));
    [~,I]=min(T);
    rx1(i)=rx1(i)+rvals(I);
end


rx=find(X==rx1(1) & Y==rx1(2) & Z==rx1(3));

%----Define Number of Internations 1-8

%-------------------------------------

%------------------------------


[rr]=ReceiveSphere(rx).whos;
PP=ReceiveSphere(rx).fieldPDP;
PP=PP(1:end-1);
TT=ReceiveSphere(rx).timePDP;
TT=TT(1:end-1);
PP_Rice=PP;
 PP=PP-max(PP);
 TT=TT-min(TT);
 TT=TT.*10.^9;

II=rr(1:end-1,1)';
GG=rr(1:end-1,2)';
NN=rr(1:end-1,3)';

values=find(GG<=Number);

II=II(values);
GG=GG(values);
NN=NN(values);
PP=PP(values);
TT=TT(values);
PP_Rice=PP_Rice(values);

[TT_New id]=sort(TT,'ascend');
II=II(id);
GG=GG(id);
NN=NN(id);
PP_New=PP(id);
PP_Rice=PP_Rice(id);

 dif=diff(TT_New);
 dif=abs(dif);
 
 if Number==1;
     Wanted=1;
 else
    Wanted=find(dif>1);
    if isempty(Wanted)==1;
        Wanted=1;
    end
 end
 
 II=II(Wanted);
 GG=GG(Wanted);
 NN=NN(Wanted);
 TT_N=TT_New(Wanted);
 PP_N=PP_New(Wanted);
 PP_Rice=PP_Rice(Wanted);

% Y axis relative received Field in dBm and X axis relative delays in
% NANOSECS

figure('Name', label);
axis1 = gca();
plot(axis1, TT_N,PP_N, 'r*');
xlabel(axis1, 'delays');
ylabel(axis1, 'received power');
title(axis1, 'PDP');
%-----------------------------------



count=1;

while count<=size(ReceiveSphere,2);
    
for i=1:size(Y,2)    

    for q=1:size(X,1)    
        
        ReceivePower(q,i)=ReceiveSphere(count).field;
        
        count=count+1;
        
    end
    
end

end

figure('Name', label);
axis2 = gca();
view(axis2, 3);
box(axis2, 'off');
surf(axis2, X,Y,Z,ReceivePower);
shading(axis2, 'interp');
hold on;
    ProCreateCity(axis2, 19);
%h=findobj('Type','Surf');
%%hh=findobj('Type','Patch');
%alpha(h,1)
%alpha(hh,0.1)
axis(axis2, "equal", "tight");
hold on;
TX=handles.tx_single;
stem3(axis2, TX(1),TX(2),TX(3)+1,'g');
ProPlotReceivedRays(axis2, II,GG,NN,Ray_PDP);
hold on;
plot3(axis2, ReceiveSphere(rx).position(1,1),ReceiveSphere(rx).position(1,2),ReceiveSphere(rx).position(1,3),'k*');
colormap(axis2, "jet");
c = colorbar(axis2, 'ytick', -180:20:0);
set(c, 'position', [0.87, 0.1, 0.05, 0.8]);
title(axis2, 'Received Power');

%----Rice Factor COmputation
if Number>1;
    Power_Rice=sort(PP_Rice,'descend');
else
Power_Rice=PP_Rice;
end

%K Factor Value
k_Rice=sum(10.^(Power_Rice(1)./10))./sum(10.^(Power_Rice(2:end)./10));

%--------------------------

%-------rms delay spread COmputation---------
P_linear=10.^(PP_N./10);
PT=sum(P_linear);

P_relative=P_linear./PT;

Mean_Delay_T0=sum(P_relative.*TT_N);

%rms delay spread value in NANOSECS
RMS_T=sqrt(sum(P_linear.*TT_N.^2)./PT-Mean_Delay_T0.^2);
%--------------------------------------------