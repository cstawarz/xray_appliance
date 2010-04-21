%% coregisters mri phantom data with xray data, forms some plots

xrayData = ...
    [32898,  05759,    01278;
    40900,   -04316,    00213;
    33918,   -04419,   -00140;
    33650,   -07630,   -00362;
    39589,   -06426,   -03053];    %%as reconstructed from paul and alex's phantom by Dan's code 
    
mriData = ...
    [ -4510, -30370,   15450;
    -5720, -32870,   12750;
    1270,  -32870,   16650;
    1370,  -32870,   13570;
    3320,  -32870,   3710]; %%as given by pauls mri data inspection by eye
    
[rigidTransformedMRIData, transformVector, MRIordering, resnorm] = ...
    mri_matchIgnoreCorrespondences(mriData, xrayData);
 
    
%% plotting the xray data
subplot(2,1,1)
hold on;

plot(xrayData(1,1), xrayData(1,3), 'or')
text(xrayData(1,1), xrayData(1,3), '   1')

plot(xrayData(2,1), xrayData(2,3), 'og')
text(xrayData(2,1), xrayData(2,3), '   2')

plot(xrayData(3,1), xrayData(3,3), 'ob')
text(xrayData(3,1), xrayData(3,3), '   3')

plot(xrayData(4,1), xrayData(4,3), 'ok')
text(xrayData(4,1), xrayData(4,3), '   4')

plot(xrayData(5,1), xrayData(5,3), 'oy')
text(xrayData(5,1), xrayData(5,3), '   5')


xlabel('LM')
ylabel('DV')
title('xrayData')
%
axis equal
v = axis;
axis([v(1)-1000, v(2)+1000, v(3)-1000, v(4)+1000])
subplot(2,1,2)

hold on
plot(xrayData(1,1), xrayData(1,2), 'or')


text(xrayData(1,1), xrayData(1,2), '   1')

plot(xrayData(2,1), xrayData(2,2), 'og')
text(xrayData(2,1), xrayData(2,2), '   2')

plot(xrayData(3,1), xrayData(3,2), 'ob')
text(xrayData(3,1), xrayData(3,2), '   3')

plot(xrayData(4,1), xrayData(4,2), 'ok')
text(xrayData(4,1), xrayData(4,2), '   4')

plot(xrayData(5,1), xrayData(5,2), 'oy')
text(xrayData(5,1), xrayData(5,2), '   5')

xlabel('LM')
ylabel('AP')
axis equal
v = axis;
axis([v(1)-1000, v(2)+1000, v(3)-1000, v(4)+1000])

figure




%%plotting the transform MRI data
subplot(2,1,1)
hold on;

plot(rigidTransformedMRIData(1,1), rigidTransformedMRIData(1,3), 'or')
text(rigidTransformedMRIData(1,1), rigidTransformedMRIData(1,3), '   1')

plot(rigidTransformedMRIData(2,1), rigidTransformedMRIData(2,3), 'og')
text(rigidTransformedMRIData(2,1), rigidTransformedMRIData(2,3), '   2')

plot(rigidTransformedMRIData(3,1), rigidTransformedMRIData(3,3), 'ob')
text(rigidTransformedMRIData(3,1), rigidTransformedMRIData(3,3), '   3')

plot(rigidTransformedMRIData(4,1), rigidTransformedMRIData(4,3), 'ok')
text(rigidTransformedMRIData(4,1), rigidTransformedMRIData(4,3), '   4')

plot(rigidTransformedMRIData(5,1), rigidTransformedMRIData(5,3), 'oy')
text(rigidTransformedMRIData(5,1), rigidTransformedMRIData(5,3), '   5')


xlabel('LM')
ylabel('DV')
title('rigidTransformedMRIData')
%
axis equal
v = axis;
axis([v(1)-1000, v(2)+1000, v(3)-1000, v(4)+1000])
subplot(2,1,2)

hold on
plot(rigidTransformedMRIData(1,1), rigidTransformedMRIData(1,2), 'or')

text(rigidTransformedMRIData(1,1), rigidTransformedMRIData(1,2), '   1')

plot(rigidTransformedMRIData(2,1), rigidTransformedMRIData(2,2), 'og')
text(rigidTransformedMRIData(2,1), rigidTransformedMRIData(2,2), '   2')

plot(rigidTransformedMRIData(3,1), rigidTransformedMRIData(3,2), 'ob')
text(rigidTransformedMRIData(3,1), rigidTransformedMRIData(3,2), '   3')

plot(rigidTransformedMRIData(4,1), rigidTransformedMRIData(4,2), 'ok')
text(rigidTransformedMRIData(4,1), rigidTransformedMRIData(4,2), '   4')

plot(rigidTransformedMRIData(5,1), rigidTransformedMRIData(5,2), 'oy')
text(rigidTransformedMRIData(5,1), rigidTransformedMRIData(5,2), '   5')

xlabel('LM')
ylabel('AP')
axis equal
v = axis;
axis([v(1)-1000, v(2)+1000, v(3)-1000, v(4)+1000]);