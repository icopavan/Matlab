clear all
close all
vncdata=load('vnc_3bands.csv');

i=1;
[m,n]=size(vncdata);
while(i<m)
    if(vncdata(i,9)==0 || vncdata(i,10)==0 ||vncdata(i,11)==0)
        vncdata(i,:)=[];    
    else
        i=i+1;
    end
    [m,n]=size(vncdata);
end

i=1;
[m,n]=size(vncdata);
while(i<m)
    index=find(vncdata(:,2)==vncdata(i,2));
    if(numel(index)>1)
        for j=1:n
            vncdata(i,j)=mean(vncdata(index,j));
        end
        for j=2:numel(index)
            vncdata(index(j),:)=[];
        end
   
    end

    i=i+1;
    
    [m,n]=size(vncdata);
end





i=1;
[m,n]=size(vncdata);
while(i<m)
    index=find(vncdata(i,12:14)==max(vncdata(i,12:14)));
    if(numel(index)==1)
    vncdata(i,1)=index;
    else
        vncdata(i,1)=index(1);
    end

    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%Find the max throughput and out put to the first column
i=1;
[m,n]=size(vncdata);
while(i<m)
    index=find(vncdata(i,12:13)==max(vncdata(i,12:13)));
    if(numel(index)==1)
    vncdata(i,1)=index;
    else
        vncdata(i,1)=index(1);
    end

    i=i+1;
end


index=find(vncdata(:,15)<0);
vncdata(index,15)=-vncdata(index,15);
index=find(vncdata(:,16)<0);
vncdata(index,16)=-vncdata(index,16);
index=find(vncdata(:,17)<0);
vncdata(index,17)=-vncdata(index,17);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%Find the min delay and out put to the 21 column
i=1;
[m,n]=size(vncdata);
while(i<m)
    index=find(vncdata(i,15:16)==min(vncdata(i,15:16)));
    if(numel(index)==1)
    vncdata(i,21)=index;
    else
        vncdata(i,21)=index(1);
    end

    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%Find the min activity of previous time 1 slot and out put to the 22 column
i=1;
[m,n]=size(vncdata);
while(i<(m-1))
    index=find(vncdata(i,18:19)==min(vncdata(i,18:19)));
    if(numel(index)==1)
    vncdata((i+1),22)=index;
    else
        vncdata((i+1),22)=index(1);
    end

    i=i+1;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Statistics the accuracy
i=1;
acc_tpt=0;
acc_delay=0;
test=0;
test_tpt=0;
[m,n]=size(vncdata);
while(i<m)
    if(vncdata(i,1)==vncdata(i,22))
        acc_tpt=acc_tpt+1;
                if(vncdata(i,1)~=1)
            test_tpt=test_tpt+1;
        end
    end
    if(vncdata(i,21)==vncdata(i,22))
        acc_delay=acc_delay+1;
                if(vncdata(i,1)~=1)
            test=test+1;
        end
    end   
    i=i+1;
end

a_tpt=acc_tpt/m*100
a_delay=acc_delay/m*100
test_tpt/m*100
test/m*100





