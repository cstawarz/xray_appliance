%%rewrites angles to all be between -180 and 180
function [newAngle] = mri_recenter(oldAngle)
    newAngle = oldAngle;
    if (newAngle<-180)
        while (newAngle<-180)
            newAngle = newAngle+360;
        end
    end
    if (newAngle>180)
        while (newAngle>180)
            newAngle = newAngle-360;
        end
    end
end