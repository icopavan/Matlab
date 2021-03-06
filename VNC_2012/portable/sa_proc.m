function out=sa_proc(sadata)
%%Mofify SA data to GPS time
sadata(:,1)=sadata(:,1)+50000;
out=sadata;
out(:,4)=floor(sadata(:,1));
%us
out(:,5)=round(mod(sadata(:,1),1)*1000000);
%%%Substract the delay on SCPI

i=1;
[m,n]=size(out);
while(i<m)
    temp=out(i,5)-95000;
    if(temp>=0)
        out(i,5)=temp;
       
    else
        out(i,5)=temp+1000000;
        if(mod(out(i,4),100)>0)
            out(i,4)=out(i,4)-1;
        else
            out(i,4)=out(i,4)-41;
        end
    end
    i=i+1;
end