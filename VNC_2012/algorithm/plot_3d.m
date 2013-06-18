

%%Input file format: 
% GPS time, Board Time, RX velocity, TX Velocity, RX Latitude, RX
% Longitude, TX latitude, TX longtitude, 4 RSSI(2.4,5.2,450,900), 4 Tpt, 4
% Delay, 4 Activity Level,4 SA data
% 

% Input data should be named as vncdata;

% Output data is tpt accuracy and delay accuracy
% Each metric has 5 value, means input 1 band RSSI for 4 bands, then input
% all four band rssi

clear all
close all

load 3d_data.mat; %%Measured data
bands=['2.4G','5.2G','450M','900M'];
%Generate 3D plot
for i=0:3
    figure
    a=meshgrid(vncdata(:,9+i));
    b=meshgrid(vncdata(:,25+i));
    c=meshgrid(vncdata(:,13+i));
    mesh(a,b,c);
    title(bands(i+1));
end



% [m,n]=size(vncdata);
% for i=1:(m-1)
% x=vncdata(i,21);%RSSI
% 
% 
% y=vncdata(i,13);%TPT
% 
% z = [vncdata(i,13)];
% plot(x,y,'*')
% hold on;
% end