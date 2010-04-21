function amount = randCenteredAtZero1(scale)
%%Generates a random number over a uniform distribution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% amount = randCenteredAtZero1(scale)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs:
%
% scale: the +maximum and -minimum of a uniform distribution (-scale, scale)
% Max of element is scale,
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs: 
% amount: a random number in  Uniform(-scale, scale)
%
%
    if (scale==0) 
        amount = scale;
    else
        amount = (-1 + 2*rand(1,1))*scale;
        %%amount = scale;
    end
end