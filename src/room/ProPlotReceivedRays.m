function ProPlotReceivedRays(currentAxis, II,GG,NN,Ray)

II=II;
GG=GG;
NN=NN;
for i=1:size(II,2)
    
while (GG(1,i)>1 && NN(1,i)>1)
    line(currentAxis, Ray(II(1,i)).children(GG(1,i),NN(1,i)).position(1,:),Ray(II(1,i)).children(GG(1,i),NN(1,i)).position(2,:),Ray(II(1,i)).children(GG(1,i),NN(1,i)).position(3,:),'color','k');
    X=II(1,i);
    Y=GG(1,i);
    Z=NN(1,i);
    GG(1,i)=Ray(X).children(Y,Z).history(1,2);
    NN(1,i)=Ray(X).children(Y,Z).history(1,3);
    
end

end

for i=1:size(II,2)
    line(currentAxis, Ray(II(1,i)).children(1,1).position(1,:),Ray(II(1,i)).children(1,1).position(2,:),Ray(II(1,i)).children(1,1).position(3,:),'color','k');
end
    