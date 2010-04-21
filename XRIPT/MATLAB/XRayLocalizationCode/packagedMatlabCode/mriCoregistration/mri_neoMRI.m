%%coregisters xray data with neo MRI data, set1

xrayCenters = ...
    [+34958,    112,  -9675;
    +29923,    451,   -3953;
    +34755,    -691,   -6487;
    +18481,   -5147,  -5396];

mriSet1 = ...
    [  17150,  -39020,    8020;
       16810,  -42190,    7520;
       21050,  -33330,   -1480;
       -1050,  -45490,    7950;
       17810,  -37260,   14020;
       21980,  -40590,   12020;
       17190,  -34210,   13520];

 centers2 = xrayCenters;
 centers1 = mriSet1;
 [newCenters1, x, centers1Ordering, residual] =  mri_matchIgnoreCorrespondencesAssymetric(centers1, centers2);
 save neoCoreg
 
