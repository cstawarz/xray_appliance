package Simulator;

import javax.vecmath.Point3d;

public abstract class Fiducial extends TransformableObject
{
//	private double radius;
	protected Fiducial(Point3d initCenter, boolean heavy, boolean movingRotationCenter)
	{
		super(initCenter, heavy, movingRotationCenter);
	}
	public Fiducial(Point3d initCenter)
	{
		super(initCenter);
	}
	
	public abstract double getRadius();	
    public abstract double getFiducialAttenuation();
}
