function ProCreateCity(currentAxis, w)

xlabel('X axis (m)')
ylabel('Y axis (m)')
zlabel('Z axis (m)')

if w==1
    
    facet=Proloadfacet1;
    lim1=21;
    lim2=26;
    
end

if (w==2 | w==3 | w==4 | w==5 | w==6)
    
    facet=Proloadfacet2;
    lim1=21;
    lim2=26;
    
end

% if w==2
%     
%     facet=Proloadfacet2;
%     lim1=21;
%     lim2=26;
%     
% end
% 
% if w==3
%     
%     facet=Proloadfacet3;
%     lim1=0;
%     lim2=0;
%     
% end
% 
% if w==4
%     
%     facet=Proloadfacet4;
%     lim1=0;
%     lim2=0;
%     
% end
% 
% if w==5
%     
%     facet=Proloadfacet5;
%     lim1=0;
%     lim2=0;
%     
% end
% 
% if w==6
%     
%     facet=Proloadfacet6;
%     lim1=0;
%     lim2=0;
%     
% end

if w==7
    
    facet=Proloadfacet7;
    lim1=1;
    lim2=6;
    
end

if w==8
    
    facet=Proloadfacet8;
    lim1=1;
    lim2=6;
    
end

if w==9
    
    facet=Proloadfacet9;
    lim1=11;
    lim2=16;
    
end

if w==10
    
    facet=Proloadfacet10;
    lim1=21;
    lim2=26;
    
end

if (w==11 | w==12)
    
    facet=Proloadfacet12;
    lim1=23;
    lim2=28;
    
end

if w==13
    
    facet=Proloadfacet13;
    lim1=21;
    lim2=26;
    
end

if w==14
    
    facet=Proloadfacet14;
    lim1=11;
    lim2=16;
    
end

if w==15
    
    facet=Proloadfacet15;
    lim1=1;
    lim2=6;
    
end

if w==16
    
    facet=ProloadfacetIndoor;
    lim1=1;
    lim2=6;
    
end
if w==17
    
    facet=ProloadfacetPhysics;
    lim1=21;
    lim2=26;
    
end

if w==18
    
    facet=ProloadfacetPhysics_Double;
    lim1=21;
    lim2=26;
    
end

if w==19
    facet = ProloadfacetCCSR;
    lim1=21;
    lim2=26;
    
end

if w==20
    
    facet=ProloadfacetCCSR_two_floors;
    lim1=21;
    lim2=26;
    
end

for i=1:size(facet,2);
%     if i>=lim1 & i<=lim2;
%         continue
%     end
    face=facet(i);
    
    if strcmp(face.type,'Limit')==1;
        continue
    end
    
%     if strcmp(face.type,'roof')==1 & face.building==5;
%         continue
%     end
    
    if strcmp(face.type,'wall')==1;
        
        W1=face.position;
        
        patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),[0.5 0.5 0.5]);
        
    end
    
    if strcmp(face.type,'window')==1;
        
        W1=face.position;
        
        patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),'c');
        
    end
    
    if strcmp(face.type,'door')==1;
        
        W1=face.position;
        
        patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),[0.9 0.9 0]);
        
    end
        
    if strcmp(face.type,'ground')==1;
        
        W1=face.position;
        
        patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),[0.2 0.2 0.2]);
        
    end
    
    if strcmp(face.type,'roof')==1;
        
        W1=face.position;
        
        patch(currentAxis,W1(:,1),W1(:,2),W1(:,3),[0.5 0.5 0.5]);
        
    end
    
    if strcmp(face.type,'floor')==1;
        
        W1=face.position;
        
        patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),[0.5 0.5 0.5]);
        
    end
    
    if strcmp(face.type,'advertisment')==1;
        
        W1=face.position;
        
        patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),'r');
        
    end

end

% W1=facet(42).position;
% patch(currentAxis, W1(:,1),W1(:,2),W1(:,3),[0.5 0.5 0.5]);

% %alpha(0.5)