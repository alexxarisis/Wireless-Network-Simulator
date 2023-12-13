function [k_Rice, RMS_T]=Plot_Rays_PDP_Along_Lines(handles)
%inputs default
%Number=8;
%rx=[14.5 25 1.5]
% %insert the lines of the receiver position. Only Vertical or Horizontal
% Xmin=5;
% Xmax=5;
% Ymin=0;
% Ymax=40;
Number = handles.interactions;
LINE = handles.line; 

label = handles.figures_title;

%%%%%%%%%%
rx1 = LINE;

dec=rx1-floor(rx1);
rx1=floor(rx1);
rvals=[0 0.25 0.5 0.75 1];
for i=1:length(dec)
    T=abs(rvals-dec(i));
    [~,I]=min(T);
    rx1(i)=rx1(i)+rvals(I);
end

Xmin=min([rx1(1) rx1(2)]);
Xmax=max([rx1(1) rx1(2)]);
Ymin=min([rx1(3) rx1(4)]);
Ymax=max([rx1(3) rx1(4)]);

ReceiveSphere=handles.ReceiveSphere;
[X,Y,Z]=meshgrid(0:0.25:45,0:0.25:45,1.5:0.25:1.5);
step=0.25;


%INPUTS

%----Define Number of Internations 1-8
%-------------------------------------
%-------------------------------

if Xmin==Xmax

    Yline=Ymin:step:Ymax;

    for vv=1:max(size(Yline));

    rx(vv,:)=find(X==Xmin & Y==Yline(vv));

    end
end

if Ymin==Ymax

    Xline=Xmin:step:Xmax;

    for vv=1:max(size(Xline));

    rx(vv,:)=find(X==Xline(vv) & Y==Ymin);

    end
end




for irx=1:max(size(rx));
    
rr=ReceiveSphere(rx(irx)).whos;
PP=ReceiveSphere(rx(irx)).fieldPDP;
PP=PP(1:end-1);
TT=ReceiveSphere(rx(irx)).timePDP;
TT=TT(1:end-1);
PP_Rice=PP;
 PP=PP-max(PP);
 TT=TT-min(TT);
 TT=TT.*10.^9;


II=rr(1:end-1,1)';
GG=rr(1:end-1,2)';
NN=rr(1:end-1,3)';

values=find(GG<=Number);

% if isempty(values)
%     for n=[Number:1:8 Number:-1:1]
%         values=find(GG<=n);
%         if ~isempty(values)
%             Number=n;
%             break;
%         end
%     end
% end

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
 end
 
 II=II(Wanted);
 GG=GG(Wanted);
 NN=NN(Wanted);
 TT_N=TT_New(Wanted);
 PP_N=PP_New(Wanted);
 PP_Rice=PP_Rice(Wanted);

%-----------------------------------


%----Rice Factor COmputation
if Number>1;
    Power_Rice=sort(PP_Rice,'descend');
else
Power_Rice=PP_Rice;
end
%K Factor Value
try
   k_Rice(irx,:)=sum(10.^(Power_Rice(1)./10))./sum(10.^(Power_Rice(2:end)./10));
catch MException
    if irx>1
      k_Rice(irx,:)=k_Rice(irx-1,:);
      RMS_T(irx,:)=RMS_T(irx-1,:);
    else
      k_Rice(irx,:)=0;
      RMS_T(irx,:)=0;
    end
    continue;
end
%--------------------------

%-------rms delay spread COmputation---------
P_linear=10.^(PP_N./10);
PT=sum(P_linear);

P_relative=P_linear./PT;

Mean_Delay_T0=sum(P_relative.*TT_N);

%rms delay spread value in NANOSECS
RMS_T(irx,:)=sqrt(sum(P_linear.*TT_N.^2)./PT-Mean_Delay_T0.^2);
%--------------------------------------------
end


if Xmin==Xmax
    figure('Name', label);
    axis1 = gca();
    plot(axis1,Yline,k_Rice);
    xlabel(axis1,'distance');
    ylabel(axis1,'K factor');
    title(axis1,'K factor over selected line.')
    
    figure('Name', label);
    axis2 = gca();
    plot(axis2,Yline,10.*log10(k_Rice))
    xlabel(axis2,'distance');
    ylabel(axis2,'10log10(K factor)');
    title(axis2,'log-scale K factor over selected line.')
    
    figure('Name', label);
    axis3 = gca();
    plot(axis3,Yline,RMS_T,'r')
    xlabel(axis3,'distance');
    ylabel(axis3,'RMS T');
    title(axis3,'RMS T over selected line.')
    
end

if Ymin==Ymax
    figure('Name', label);
    axis1 = gca();
    plot(axis1, Yline,(k_Rice))    
    xlabel(axis1, 'distance');
    ylabel(axis1, 'K factor');
    title(axis1, 'K factor over selected line.')
    
    figure('Name', label);
    axis2 = gca();
    plot(axis2, Yline,10.*log10(k_Rice))
    xlabel(axis2, 'distance');
    ylabel(axis2, '10log10(K factor)');
    title(axis2, 'log-scale K factor over selected line.')
    
    figure('Name', label);
    axis3 = gca();
    plot(axis3, Yline,RMS_T,'r')
    xlabel(axis3, 'distance');
    ylabel(axis3, 'RMS T');
    title(axis3, 'RMS T over selected line.')
end

    

count=1;

imaginary=j;
while count<=size(ReceiveSphere,2);
    
  for i=1:size(Y,2)    

    for q=1:size(X,1)    
        
        ReceivePower(q,i)=ReceiveSphere(count).field;
        
        count=count+1;
        
    end
    
  end

end



figure('Name', label);
axis4 = gca();
view(axis4, 3);
box(axis4, 'off');
surf(axis4, X,Y,Z,ReceivePower);
shading(axis4, 'interp');
hold on;
    ProCreateCity(axis4, 19);
%h=findobj('Type','Surf');
%hh=findobj('Type','Patch');
%%%alpha(h,1);
%%%alpha(hh,0.1);
axis(axis4, "equal", "tight");
TX=handles.tx_single;
stem3(axis4, TX(1),TX(2),TX(3)+1,'g');
line(axis4, [Xmin Xmax],[Ymin Ymax],[1.5 1.5],'linewidth',2,'color','red');
colormap(axis4, "jet");
c = colorbar(axis4, 'ytick', -180:20:0);
set(c, 'position', [0.87, 0.1, 0.05, 0.8]);
title(axis4, 'received power')
