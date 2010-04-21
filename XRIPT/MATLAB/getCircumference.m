 

function circumference = getCircumference(x,y);

%Get circumference of a boundary by computing the sum of adjacent elements in
%x and y
Xdiffs = diff(x);
Xdiffs(end+1) = x(end)-x(1);

Ydiffs = diff(y);
Ydiffs(end+1) = y(end)-y(1);

circumference = sum(sqrt(abs(Xdiffs).^2 + abs(Ydiffs).^2));
