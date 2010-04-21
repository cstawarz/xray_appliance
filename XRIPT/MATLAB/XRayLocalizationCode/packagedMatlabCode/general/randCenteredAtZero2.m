function amount = randCenteredAtZero2(scale, rows, cols)
%%Generates an array over a uniform distribution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% amount = randCenteredAtZero1(scale, rows, cols)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%
% scale: the +maximum and -minimum of a uniform distribution (-scale, scale)
% Max of element is scale,
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs: 
% amount: a rows by colls array, where each element is a different random random number in  Uniform(-scale, scale)
%

     %%call "rand('state',sum(100*clock))" before using this funciton to make sure things are random.  
     amount = (-1*ones(rows,cols) + 2*rand(rows,cols))*scale;
end