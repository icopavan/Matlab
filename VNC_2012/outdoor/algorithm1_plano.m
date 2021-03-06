clear all
close all
load region;
load ideal_24.csv;
load ideal_52.csv;
load ideal_45.csv;
load ideal_90.csv;


ideal_24=dips(ideal_24);
ideal_52=dips(ideal_52);
ideal_45=dips(ideal_45);
ideal_90=dips(ideal_90);




per_cont24=performance_context(ideal_24);
per_cont52=performance_context(ideal_52);
per_cont45=performance_context(ideal_45);
per_cont90=performance_context(ideal_90);



% figure
% plot(ideal_24(:,1),ideal_24(:,2),'*')
% hold on
% plot(per_cont24(:,1),per_cont24(:,2),'r')
% figure
% plot(ideal_52(:,1),ideal_52(:,2),'*')
% hold on
% plot(per_cont52(:,1),per_cont52(:,2),'r')
%Normalize the ideal lookup table
max_t_24=norm_para(per_cont24);
max_t_52=norm_para(per_cont52);
max_t_45=norm_para(per_cont45);
max_t_90=norm_para(per_cont90);


per_cont24(:,2)=per_cont24(:,2)/max_t_24;
per_cont52(:,2)=per_cont52(:,2)/max_t_52;
per_cont45(:,2)=per_cont45(:,2)/max_t_45;
per_cont90(:,2)=per_cont90(:,2)/max_t_90;


%%%Normalize measured data
vncdata(:,13)=vncdata(:,13)/max_t_45;
vncdata(:,14)=vncdata(:,14)/max_t_24;
vncdata(:,15)=vncdata(:,15)/max_t_52;
vncdata(:,16)=vncdata(:,16)/max_t_90;




perest_tpt(:,1:4)=vncdata(:,9:12);
perest_delay(:,1:4)=vncdata(:,9:12);


[perest_tpt(:,5),perest_delay(:,5)]=performance_estimate(perest_tpt(:,1),per_cont45);
[perest_tpt(:,6),perest_delay(:,6)]=performance_estimate(perest_tpt(:,2),per_cont24);
[perest_tpt(:,7),perest_delay(:,7)]=performance_estimate(perest_tpt(:,3),per_cont52);
[perest_tpt(:,8),perest_delay(:,8)]=performance_estimate(perest_tpt(:,4),per_cont90);

%%%Consider the activity level

perest_tpt(:,9)=activity_tpt(vncdata(:,21),perest_tpt(:,5));
perest_tpt(:,10)=activity_tpt(vncdata(:,22),perest_tpt(:,6));
perest_tpt(:,11)=activity_tpt(vncdata(:,23),perest_tpt(:,7));
perest_tpt(:,12)=activity_tpt(vncdata(:,24),perest_tpt(:,8));


perest_tpt(:,13)=stat_max(vncdata(:,13:16));
perest_tpt(:,14)=stat_max(perest_tpt(:,9:12));
perest_tpt(:,15)=stat_max(perest_tpt(:,5:8));


perest_delay(:,9)=activity_delay(vncdata(:,21),perest_delay(:,5));
perest_delay(:,10)=activity_delay(vncdata(:,22),perest_delay(:,6));
perest_delay(:,11)=activity_delay(vncdata(:,23),perest_delay(:,7));
perest_delay(:,12)=activity_delay(vncdata(:,24),perest_delay(:,8));

% %%%%Find the min delay and out put to the 21 column

perest_delay(:,13)=stat_min(vncdata(:,17:20));
perest_delay(:,14)=stat_min(perest_delay(:,9:12));
perest_delay(:,15)=stat_min(perest_delay(:,5:8));


tpt_ideal_acc=accuracy_sta(perest_tpt(:,13),perest_tpt(:,15))
tpt_act_acc=accuracy_sta(perest_tpt(:,13),perest_tpt(:,14))


delay_ideal_acc=accuracy_sta(perest_delay(:,13),perest_delay(:,15))
delay_act_acc=accuracy_sta(perest_delay(:,13),perest_delay(:,14))



