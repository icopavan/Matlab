close all
clear all

%Load data

band_info=['24';'52';'45';'90'];
[N,n]=size(band_info);
context_info=char('gps','delay','throughput','sa','pkt');
[M,n]=size(context_info);

for i=1:M
    for j=1:N
        ld_file=strcat(context_info(i,:),'_',band_info(j,:),'.csv');
        load(ld_file);
    end    
end


%average the throughput
tpt_24=avr_tpt(throughput_24);
tpt_52=avr_tpt(throughput_52);
tpt_45=avr_tpt(throughput_45);
tpt_90=avr_tpt(throughput_90);

%%Synchronize rx information
temp=syn_gpstime(tpt_24,1,delay_24,1);
%GPStime, velocity, rx latitude,rx longtitude,throughput, activitylevel,delay,
rx_24=[temp(:,1:5),temp(:,11),temp(:,14:15)];

temp=syn_gpstime(tpt_45,1,delay_45,1);
%GPStime, velocity, rx latitude,rx longtitude,throughput, delay, activitylevel
rx_45=[temp(:,1:5),temp(:,11),temp(:,14:15)];

temp=syn_gpstime(tpt_52,1,delay_52,1);
%GPStime, velocity, rx latitude,rx longtitude,throughput, delay, activitylevel
rx_52=[temp(:,1:5),temp(:,11),temp(:,14:15)];

temp=syn_gpstime(tpt_90,1,delay_90,1);
%GPStime, velocity, rx latitude,rx longtitude,throughput, delay, activitylevel
rx_90=[temp(:,1:5),temp(:,11),temp(:,14:15)];

%%Synchronize RX, TX information
%GPStime, velocity, rx latitude,rx longtitude,throughput, delay,
%activitylevel
temp=syn_gpstime(rx_24,1,gps_24,1);
out_24=[temp(:,1),temp(:,3:4),temp(:,11:12),temp(:,2),temp(:,10),temp(:,5:8)];

temp=syn_gpstime(rx_45,1,gps_45,1);
out_45=[temp(:,1),temp(:,3:4),temp(:,11:12),temp(:,2),temp(:,10),temp(:,5:8)];

temp=syn_gpstime(rx_52,1,gps_52,1);
out_52=[temp(:,1),temp(:,3:4),temp(:,11:12),temp(:,2),temp(:,10),temp(:,5:8)];

temp=syn_gpstime(rx_90,1,gps_90,1);
out_90=[temp(:,1),temp(:,3:4),temp(:,11:12),temp(:,2),temp(:,10),temp(:,5:8)];

%%%Synchronize RX,TX and SA data

%%Mofify SA data to GPS time
sa_24=sa_proc(sa_24);
sa_45=sa_proc(sa_45);
sa_52=sa_proc(sa_52);
sa_90=sa_proc(sa_90);

pkt_24=pkt_proc(pkt_24);
pkt_45=pkt_proc(pkt_45);
pkt_52=pkt_proc(pkt_52);
pkt_90=pkt_proc(pkt_90);
% pkt_24(:,2)=round(mod(pkt_24(:,2),1)*1000000);
% pkt_45(:,2)=round(mod(pkt_45(:,2),1)*1000000);
% pkt_52(:,2)=round(mod(pkt_52(:,2),1)*1000000);
% pkt_90(:,2)=round(mod(pkt_90(:,2),1)*1000000);

%Substract the value from RSSI SA data point comparing with pkt collected from tcpdump
sa_clission_24=sa_syn(sa_24,pkt_24);
sa_clission_45=sa_syn(sa_45,pkt_45);
sa_clission_52=sa_syn(sa_52,pkt_52);
sa_clission_90=sa_syn(sa_90,pkt_90);

%%Synchronize to the same second

sa_sec_24=avr_sa_sec(sa_clission_24);
sa_sec_45=avr_sa_sec(sa_clission_45);
sa_sec_52=avr_sa_sec(sa_clission_52);
sa_sec_90=avr_sa_sec(sa_clission_90);



%%Syn the final data

temp=syn_gpstime(out_24,1,sa_sec_24,1);
temp(:,12)=[];
out_24=temp;

temp=syn_gpstime(out_45,1,sa_sec_45,1);
temp(:,12)=[];
out_45=temp;

temp=syn_gpstime(out_52,1,sa_sec_52,1);
temp(:,12)=[];
out_52=temp;

temp=syn_gpstime(out_90,1,sa_sec_90,1);
temp(:,12)=[];
out_90=temp;



%Generate out put csv file
dlmwrite('portable_24.csv',out_24,'delimiter',',','precision','%.12f');
dlmwrite('portable_45.csv',out_45,'delimiter',',','precision','%.12f');
dlmwrite('portable_52.csv',out_52,'delimiter',',','precision','%.12f');
dlmwrite('portable_90.csv',out_90,'delimiter',',','precision','%.12f');





