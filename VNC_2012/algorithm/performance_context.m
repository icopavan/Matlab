function out=performance_context(input_context)

per_h=ceil(max(input_context(:,1)));
per_l=floor(min(input_context(:,1)));




%Performance context 450M
out(:,1)=per_l:per_h;

i=1;
[m,n]=size(out);
while(i<=m)
    index_in1=find(input_context(:,1)>(out(i,1)-1));
    index_in2=find(input_context(index_in1,1)<(out(i,1)+1));
    
    out(i,2)=mean(input_context(index_in2,2));%Context
    out(i,3)=mean(input_context(index_in2,3));%Context
    i=i+1;
end