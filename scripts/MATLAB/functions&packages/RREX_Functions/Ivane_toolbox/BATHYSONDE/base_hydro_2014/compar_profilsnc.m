
jj=find(tmp_anc==-9999);

tmp_anc(jj) = NaN;
dep_anc(jj) = NaN;
sal_anc(jj) = NaN;

jj=find(tmp_nou==-9999);
tmp_nou(jj) = NaN;
dep_nou(jj) = NaN;
sal_nou(jj) = NaN;

for i=100:120
figure
plot(tmp_anc(i,:),-dep_anc(i,:),'r',tmp_nou(i,:),-dep_nou(i,:),'g')
xlabel('tmp');
ylabel('dep');
title (['station ' num2str(i)],'FontSize',11)

figure
plot(tmp_anc(i,:) - tmp_nou(i,:),-dep_anc(i,:),'b')
xlabel('tmp');
ylabel('dep');
title (['station ' num2str(i)],'FontSize',11)

figure
plot(sal_anc(i,:),-dep_anc(i,:),'r',sal_nou(i,:),-dep_nou(i,:),'g')
xlabel('sal');
ylabel('dep');
title (['station ' num2str(i)],'FontSize',11)

figure
plot(sal_anc(i,:) - sal_nou(i,:),-dep_anc(i,:),'b')
xlabel('sal');
ylabel('dep');
title (['station ' num2str(i)],'FontSize',11)
end


