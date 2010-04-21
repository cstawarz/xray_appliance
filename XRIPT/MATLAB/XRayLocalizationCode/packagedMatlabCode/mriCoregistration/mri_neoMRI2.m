%%coregisters xray data with neo MRI data, set2

xrayCenters = ...
    [+34958,    112,  -9675;
    +29923,    451,   -3953;
    +34755,    -691,   -6487;
    +18481,   -5147,  -5396];


mriSet2 = ...
   [17200,  -34260,   13740;
    17730,  -37880,   12740;
    21800,  -41260,   11740;
    16470,  -42170,    0740;
    18380,  -37860,    0740;
    19620,  -45290,   -0260];


 centers2 = xrayCenters;
 centers1 = mriSet2;
 [newCenters1, x, centers1Ordering, residual] =  mri_matchIgnoreCorrespondencesAssymetric(centers1, centers2);
 save neoCoreg2