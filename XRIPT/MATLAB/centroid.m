function [Cx,Cy] = centroid(A)
%CENTROID	Find the centroid of a 2-D matrix.  Return x and y coordinates.
%
[m n]=size(A);
mass=sum(sum(A));
Cx=0;
for i=1:m
  for j=1:n
    Cx=Cx+A(i,j)*j;
  end
end
Cx=Cx/mass;
%
Cy=0;
for i=1:m
  for j=1:n
    Cy=Cy+A(i,j)*i;
  end
end
Cy=Cy/mass;
