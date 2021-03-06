

%%Input file format: 
% GPS time, Board Time, RX velocity, TX Velocity, RX Latitude, RX
% Longitude, TX latitude, TX longtitude, 4 RSSI(2.4,5.2,450,900), 4 Tpt, 4
% Delay, 4 Activity Level
% 

% Input data should be named as vncdata;

% Output data is tpt accuracy and delay accuracy
% Each metric has 5 value, means input 1 band RSSI for 4 bands, then input
% all four band rssi

clear all
close all

load park_group.mat; %%Measured data
load ideal_24.csv;
load ideal_52.csv;
load ideal_45.csv;
load ideal_90.csv;

for i=2:5
    temp=vncdata(:,i*4+1);
    vncdata(:,i*4+1)=vncdata(:,i*4+3);
    vncdata(:,i*4+3)=vncdata(:,i*4+2);
    vncdata(:,i*4+2)=temp;    
    
end

[ideal_24,nor_24,nor_delay_24]=normalize_tpt(ideal_24);
[ideal_52,nor_52,nor_delay_52]=normalize_tpt(ideal_52);
[ideal_45,nor_45,nor_delay_45]=normalize_tpt(ideal_45);
[ideal_90,nor_90,nor_delay_90]=normalize_tpt(ideal_90);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data Pre-process, make the data normalize to the performance on the
%% emulator
%Normalize Input data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%

nor=[nor_24,nor_52,nor_45,nor_90];
for i=13:16
    vncdata(:,i)=vncdata(:,i)/nor(i-12);
end

nor=[nor_delay_24,nor_delay_52,nor_delay_45,nor_delay_90];
for i=17:20
    vncdata(:,i)=vncdata(:,i)/nor(i-16);
end



% figure
% 
% plot(ideal_24(:,1),ideal_24(:,3),'x');
% hold on;
% plot(ideal_52(:,1),ideal_52(:,3),'rv');
% 
% plot(ideal_45(:,1),ideal_45(:,3),'k*');
% plot(ideal_90(:,1),ideal_90(:,3),'go');


snrest=vncdata(:,9:12);

l45=3*10^8/450/10^6;
l90=3*10^8/900/10^6;
l24=3*10^8/2.4/10^9;
l52=3*10^8/5.2/10^9;

db45=10*log10(l45);
db90=10*log10(l90);
db24=10*log10(l24);
db52=10*log10(l52);


%Pathloss exponent calculation
 snrest(:,5)=path_snrest(snrest(:,1),db45,db45);
 snrest(:,6)=path_snrest(snrest(:,1),db45,db24);
 snrest(:,7)=path_snrest(snrest(:,1),db45,db52);
 snrest(:,8)=path_snrest(snrest(:,1),db45,db90);
 


context45=context_table(snrest(:,1:4),1,2,3,4);
context24=context_table(snrest(:,1:4),2,1,3,4);
context52=context_table(snrest(:,1:4),3,1,2,4);
context90=context_table(snrest(:,1:4),4,1,2,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Given 450MHz estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%snrest colum 9-12 estimation from 450MHz
% i=1;
% [m,n]=size(snrest);
% while(i<=m)
%     in_snr=ceil(snrest(i,1));
%     index=find(context45(:,1)==in_snr);
%     snrest(i,9:12)=context45(index,:);
%     i=i+1;
% end

snrest(:,9:12)=ideal_est(snrest(:,1),context45);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Given 2.4GHz estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%snrest colum 13-16 estimation from 2.4GHz, 2.4,450,5G,900M

snrest(:,13:16)=ideal_est(snrest(:,2),context24);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Given 5GHz estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%snrest colum 17-20 estimation from 5GHz, 5,450,2.4G,900M
snrest(:,17:20)=ideal_est(snrest(:,3),context52);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Given 900MHz estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%snrest colum 21-24 estimation from 900MHz, 900,450,2.4G,5G
snrest(:,21:24)=ideal_est(snrest(:,4),context90);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Estimate the performance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Measured Data
perest_tpt=vncdata(:,13:16);
perest_delay=vncdata(:,17:20);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%without activity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%Make the performance context 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Performance context 450M
% per_cont45(:,1)=per_cont45_l:per_cont45_h;
% 
% i=1;
% [m,n]=size(per_cont45);
% while(i<=m)
%     index1=find(ideal_45(:,1)>(per_cont45(i,1)-1));
%     index2=find(ideal_45(index1,1)<(per_cont45(i,1)+1));
%     
%     per_cont45(i,2)=mean(ideal_45(index2,2));%2.4GHz context
%     per_cont45(i,3)=mean(ideal_45(index2,3));%2.4GHz context
%     i=i+1;
% end


%Quantilize the SNR
per_cont45=performance_context(ideal_45);
per_cont24=performance_context(ideal_24);
per_cont52=performance_context(ideal_52);
per_cont90=performance_context(ideal_90);








%Here change the code to function and use for new data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Estimate Performance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[perest_tpt(:,5),perest_delay(:,5)]=performance_estimate(snrest(:,5),per_cont45);
[perest_tpt(:,6),perest_delay(:,6)]=performance_estimate(snrest(:,6),per_cont24);
[perest_tpt(:,7),perest_delay(:,7)]=performance_estimate(snrest(:,7),per_cont52);
[perest_tpt(:,8),perest_delay(:,8)]=performance_estimate(snrest(:,8),per_cont90);


[perest_tpt(:,9),perest_delay(:,9)]=performance_estimate(snrest(:,9),per_cont45);
[perest_tpt(:,10),perest_delay(:,10)]=performance_estimate(snrest(:,10),per_cont24);
[perest_tpt(:,11),perest_delay(:,11)]=performance_estimate(snrest(:,11),per_cont52);
[perest_tpt(:,12),perest_delay(:,12)]=performance_estimate(snrest(:,12),per_cont90);

[perest_tpt(:,13),perest_delay(:,13)]=performance_estimate(snrest(:,13),per_cont45);
[perest_tpt(:,14),perest_delay(:,14)]=performance_estimate(snrest(:,14),per_cont24);
[perest_tpt(:,15),perest_delay(:,15)]=performance_estimate(snrest(:,15),per_cont52);
[perest_tpt(:,16),perest_delay(:,16)]=performance_estimate(snrest(:,16),per_cont90);

[perest_tpt(:,17),perest_delay(:,17)]=performance_estimate(snrest(:,17),per_cont45);
[perest_tpt(:,18),perest_delay(:,18)]=performance_estimate(snrest(:,18),per_cont24);
[perest_tpt(:,19),perest_delay(:,19)]=performance_estimate(snrest(:,19),per_cont52);
[perest_tpt(:,20),perest_delay(:,20)]=performance_estimate(snrest(:,20),per_cont90);

[perest_tpt(:,21),perest_delay(:,21)]=performance_estimate(snrest(:,21),per_cont45);
[perest_tpt(:,22),perest_delay(:,22)]=performance_estimate(snrest(:,22),per_cont24);
[perest_tpt(:,23),perest_delay(:,23)]=performance_estimate(snrest(:,23),per_cont52);
[perest_tpt(:,24),perest_delay(:,24)]=performance_estimate(snrest(:,24),per_cont90);

[perest_tpt(:,25),perest_delay(:,25)]=performance_estimate(snrest(:,1),per_cont45);
[perest_tpt(:,26),perest_delay(:,26)]=performance_estimate(snrest(:,2),per_cont24);
[perest_tpt(:,27),perest_delay(:,27)]=performance_estimate(snrest(:,3),per_cont52);
[perest_tpt(:,28),perest_delay(:,28)]=performance_estimate(snrest(:,4),per_cont90);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Got all the one band estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Consider the activity level


for i=25:28
    perest_tpt(:,i)=perest_tpt(:,i).*(1-vncdata(:,(i-4)));
    perest_delay(:,i)=perest_delay(:,i)./(1-vncdata(:,(i-4)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate the accuracy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=1;
[m,n]=size(perest_tpt);
total_tpt=0;
total_delay=0;

while(i<=m)
    tpt_real=perest_tpt(i,1:4);
    delay_real=perest_delay(i,1:4);
    tpt_a1_path=perest_tpt(i,5:8);
    delay_a1_path=perest_delay(i,5:8);
    tpt_a1_45=perest_tpt(i,9:12);
    delay_a1_45=perest_delay(i,9:12);
    tpt_a1_24=perest_tpt(i,13:16);
    delay_a1_24=perest_delay(i,13:16);
    tpt_a1_52=perest_tpt(i,17:20);
    delay_a1_52=perest_delay(i,17:20);
    tpt_a1_90=perest_tpt(i,21:24);
    delay_a1_90=perest_delay(i,21:24);
    tpt_a1_rssi=perest_tpt(i,25:28);
    delay_a1_rssi=perest_delay(i,25:28);
    
    index_tpt_real=find(tpt_real==max(tpt_real));
    index_tpt_path=find(tpt_a1_path==max(tpt_a1_path));
    index_tpt_45=find(tpt_a1_45==max(tpt_a1_45));
    index_tpt_24=find(tpt_a1_24==max(tpt_a1_24));
    index_tpt_52=find(tpt_a1_52==max(tpt_a1_52));
    index_tpt_90=find(tpt_a1_90==max(tpt_a1_90));
    index_tpt_rssi=find(tpt_a1_rssi==max(tpt_a1_rssi));

    index_delay_real=find(delay_real==min(delay_real));
    index_delay_path=find(delay_a1_path==min(delay_a1_path));
    index_delay_45=find(delay_a1_45==min(delay_a1_45));
    index_delay_24=find(delay_a1_24==min(delay_a1_24));
    index_delay_52=find(delay_a1_52==min(delay_a1_52));
    index_delay_90=find(delay_a1_90==min(delay_a1_90));    
    index_delay_rssi=find(delay_a1_rssi==min(delay_a1_rssi));    
    
    
    if(index_tpt_real==index_tpt_path)
        acc_tpt(i,1)=1;
    else
        acc_tpt(i,1)=0;
    end
    if(index_tpt_real==index_tpt_45)
        acc_tpt(i,2)=1;
    else
        acc_tpt(i,2)=0;
    end
    
    if(index_tpt_real==index_tpt_24)
        acc_tpt(i,3)=1;
    else
        acc_tpt(i,3)=0;
    end
    
    
    if(index_tpt_real==index_tpt_52)
        acc_tpt(i,4)=1;
    else
        acc_tpt(i,4)=0;
    end
    
    
    if(index_tpt_real==index_tpt_90)
        acc_tpt(i,5)=1;
    else
        acc_tpt(i,5)=0;
    end
    
    if(index_tpt_real==index_tpt_rssi)
        acc_tpt(i,6)=1;
    else
        acc_tpt(i,6)=0;
    end
    
    %Calculate the throughput GAP
    total_tpt=total_tpt+tpt_real(index_tpt_real);
    penality(i)=(tpt_real(index_tpt_real)-tpt_real(index_tpt_rssi));
    
    
    %%Calculate delay accuracy
   if(index_delay_real==index_delay_path)
        acc_delay(i,1)=1;
    else
        acc_delay(i,1)=0;
    end
    if(index_delay_real==index_delay_45)
        acc_delay(i,2)=1;
    else
        acc_delay(i,2)=0;
    end
    
    if(index_delay_real==index_delay_24)
        acc_delay(i,3)=1;
    else
        acc_delay(i,3)=0;
    end
    
    
    if(index_delay_real==index_delay_52)
        acc_delay(i,4)=1;
    else
        acc_delay(i,4)=0;
    end
    
    
    if(index_delay_real==index_delay_90)
        acc_delay(i,5)=1;
    else
        acc_delay(i,5)=0;
    end    
    
    if(index_delay_real==index_delay_rssi)
        acc_delay(i,6)=1;
    else
        acc_delay(i,6)=0;
    end    
    
    
    total_delay=total_delay+delay_real(index_delay_rssi);
    penal_delay(i)=(-delay_real(index_delay_real)+delay_real(index_delay_rssi));
    
    
    
    
    
    i=i+1;
end


[accuracy_path,n]=size(find(acc_tpt(:,1)==1));
[accuracy_45,n]=size(find(acc_tpt(:,2)==1));
[accuracy_24,n]=size(find(acc_tpt(:,3)==1));
[accuracy_52,n]=size(find(acc_tpt(:,4)==1));
[accuracy_90,n]=size(find(acc_tpt(:,5)==1));
[accuracy_rssi,n]=size(find(acc_tpt(:,6)==1));

[m,n]=size(vncdata);

tpt_out(1)=accuracy_path/m;
tpt_out(2)=accuracy_45/m;
tpt_out(3)=accuracy_24/m;
tpt_out(4)=accuracy_52/m;
tpt_out(5)=accuracy_90/m;
tpt_out(6)=accuracy_rssi/m;
tpt_out
GAP_tpt=sum(penality)/total_tpt

[accuracy_path,n]=size(find(acc_delay(:,1)==1));
[accuracy_45,n]=size(find(acc_delay(:,2)==1));
[accuracy_24,n]=size(find(acc_delay(:,3)==1));
[accuracy_52,n]=size(find(acc_delay(:,4)==1));
[accuracy_90,n]=size(find(acc_delay(:,5)==1));
[accuracy_rssi,n]=size(find(acc_delay(:,6)==1));

delay_out(1)=accuracy_path/m;
delay_out(2)=accuracy_45/m;
delay_out(3)=accuracy_24/m;
delay_out(4)=accuracy_52/m;
delay_out(5)=accuracy_90/m;
delay_out(6)=accuracy_rssi/m;
delay_out

GAP_delay=sum(penal_delay)/total_delay
