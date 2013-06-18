cd ~/VNC_2012/outdoor/
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Load raw data                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load delay_24.csv;
load delay_52.csv;
load delay_70.csv;
load delay_90.csv;
load gps_tx.csv;
load throughput_24.csv;
load throughput_52.csv;
load throughput_70.csv;
load throughput_90.csv;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Syn delay 70,90
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
i=1;
[m,n]=size(delay_70);
while(i<m)
    index=find(delay_90(:,2)==delay_70(i,2));
if(numel(index)>0)
    delay_70(i,7)=mean(delay_90(index,6));
    delay_70(i,11)=mean(delay_90(index,10)); 
    delay_70(i,12)=mean(delay_90(index,9)); 
end
    
    
i=i+1;  
%[m,n]=size(delay_70);
end  





i=1;
[m,n]=size(delay_52);
while(i<m)
    index=find(delay_24(:,2)==delay_52(i,2));
    if(numel(index)>0)
    delay_52(i,7)=mean(delay_24(index,6));
    delay_52(i,11)=mean(delay_24(index,10));
    delay_52(i,12)=mean(delay_24(index,9));
    end
i=i+1;  
%[m,n]=size(delay_24);
end  







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Syn throughput 70,90,24,52
%%%Syn delay 70,90,24,52
i=1;
[m,n]=size(throughput_70);
while(i<m)
    index=find(throughput_90(:,1)==throughput_70(i,1)); %Synchronize 90
    if(numel(index)>0)
    throughput_70(i,6)=mean(throughput_90(index,5));
    end
    index=find(throughput_24(:,1)==throughput_70(i,1)); %Synchronize 24
    
    if(numel(index)>0)
    throughput_70(i,7)=mean(throughput_24(index,5));
    throughput_70(i,2)=(throughput_70(i,2)+mean(throughput_24(index,2)))/2;
    throughput_70(i,3)=(throughput_70(i,3)+mean(throughput_24(index,3)))/2;
    throughput_70(i,4)=(throughput_70(i,4)+mean(throughput_24(index,4)))/2;
    end
    
    index=find(throughput_52(:,1)==throughput_70(i,1)); %Synchronize 52
    if(numel(index)>0)
        throughput_70(i,8)=mean(throughput_52(index,5));
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%Syn delay 70 with tpt 70
    index=find(delay_70(:,1)==throughput_70(i,1)); %Synchronize 70,90
    if(numel(index)>0)
        throughput_70(i,9)=mean(delay_70(index,6));        
        throughput_70(i,10)=mean(delay_70(index,7));
        throughput_70(i,13)=mean(delay_70(index,10));
        throughput_70(i,14)=mean(delay_70(index,11));
        throughput_70(i,17)=mean(delay_70(index,9));
        throughput_70(i,18)=mean(delay_70(index,12));        
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%Syn delay 52 with tpt 70
    index=find(delay_52(:,1)==throughput_70(i,1)); %Synchronize 70,90
    if(numel(index)>0)
        throughput_70(i,11)=mean(delay_52(index,7));        
        throughput_70(i,12)=mean(delay_52(index,6));
        throughput_70(i,15)=mean(delay_52(index,11));
        throughput_70(i,16)=mean(delay_52(index,10));
        throughput_70(i,19)=mean(delay_52(index,12));
        throughput_70(i,20)=mean(delay_52(index,9));
        
    end    
    
    
    %%%%%%%%%%%%%%%%%%%%%Syn TX gps
    index=find(gps_tx(:,1)==throughput_70(i,1)); %Synchronize 70,90
    if(numel(index)>0)
        throughput_70(i,21)=mean(gps_tx(index,2));        
        throughput_70(i,22)=mean(gps_tx(index,3));
        throughput_70(i,23)=mean(gps_tx(index,4));
    end    
    
    
    
    
     i=i+1;  
%[m,n]=size(throughput_70);
    
end  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Reshape the output and calculate the max of throughput and delay


vnc_neighbor(:,2:3)=throughput_70(:,1:2); %GPS time rx-velocity
vnc_neighbor(:,4)=throughput_70(:,21);% tx-velocity
vnc_neighbor(:,5:6)=throughput_70(:,3:4);% rx latitude,longtitude
vnc_neighbor(:,7:8)=throughput_70(:,22:23);%tx latitude,longitude

%%%%%%SNR
vnc_neighbor(:,9)=throughput_70(:,11);% 2412 snr
vnc_neighbor(:,10)=throughput_70(:,9);% 2468 snr
vnc_neighbor(:,11)=throughput_70(:,12);% 5180 snr
vnc_neighbor(:,12)=throughput_70(:,10);% 5805 snr
%%%%%%%throughput
vnc_neighbor(:,13)=throughput_70(:,7);% 2412
vnc_neighbor(:,14)=throughput_70(:,5);% 2468
vnc_neighbor(:,15)=throughput_70(:,8);% 5180
vnc_neighbor(:,16)=throughput_70(:,6);% 5805

%%%%%%%delay
vnc_neighbor(:,17)=throughput_70(:,19);% 2412
vnc_neighbor(:,18)=throughput_70(:,17);% 2468
vnc_neighbor(:,19)=throughput_70(:,20);% 5180
vnc_neighbor(:,20)=throughput_70(:,18);% 5805

%%%%%%activity
vnc_neighbor(:,21)=throughput_70(:,15);% 2412
vnc_neighbor(:,22)=throughput_70(:,13);% 2468
vnc_neighbor(:,23)=throughput_70(:,16);% 5180
vnc_neighbor(:,24)=throughput_70(:,14);% 5805





i=1;
[m,n]=size(vnc_neighbor);
while(i<m)
    index=find(vnc_neighbor(i,13:16)==max(vnc_neighbor(i,13:16)));
    if(numel(index)==1)
    vnc_neighbor(i,1)=index;
    end
    
    %Change gps style
    temp=floor(vnc_neighbor(i,5)/100)+mod(vnc_neighbor(i,5),100)/60;
    vnc_neighbor(i,5)=temp;
    temp=floor(vnc_neighbor(i,6)/100)+mod(vnc_neighbor(i,6),100)/60;
    vnc_neighbor(i,6)=0-temp;
    
    temp=floor(vnc_neighbor(i,7)/100)+mod(vnc_neighbor(i,7),100)/60;
    vnc_neighbor(i,7)=temp;
    
    temp=floor(vnc_neighbor(i,8)/100)+mod(vnc_neighbor(i,8),100)/60;
    vnc_neighbor(i,8)=0-temp;
    
    
    
i=i+1;  
%[m,n]=size(delay_24);
end  

dlmwrite('vnc_neighbor.csv',vnc_neighbor,'delimiter',',','precision','%.12f');











