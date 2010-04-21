/*
 * Created on Nov 3, 2004
 *
 
 */
package Simulator;

import java.util.Iterator;

import javax.media.j3d.Transform3D;
import javax.vecmath.Point2d;
import javax.vecmath.Point3d;
import javax.vecmath.Vector3d;

/**
 * @author dan
 */
public class SourceDetectorPair extends TransformableObject 
{
	private Source source;
	private DetectorArray detector;
	
	 //should be local to get idealCentersOfProjection - optimization to avoid 
	//reallocating memory
    private Point3d attenuatingPoint = new Point3d();
    private Vector3d direction = new Vector3d(); 
    private BasisCollection detectorOrientation = new BasisCollection();
    private Point2d projectedCenter = new Point2d();
    private Vector3d sourceToDetector = new Vector3d();
    private Vector3d intersect = new Vector3d();
	private Vector3d srcVector = new Vector3d();
	private Vector3d detectorCenterVector = new Vector3d();
	private Vector3d detectorNormal = new Vector3d();
	private double numerator = 0;
	
	private SourceDetectorPair(Source s, DetectorArray d, Point3d center)
	{
		
		super(center, true, false);
		//System.out.println(d);
		source = s;
		detector = d;
		this.addChild(s);
		this.addChild(d);
		
		//variables exclusively used by get ideal centeres of projection
		attenuatingPoint = new Point3d();
	    direction = new Vector3d(); 
	    detectorOrientation = new BasisCollection();
	    projectedCenter = new Point2d();
	    sourceToDetector = new Vector3d();
	    intersect = new Vector3d();
		srcVector = new Vector3d();
		detectorCenterVector = new Vector3d();
		detectorNormal = new Vector3d();
		numerator = 0;
		
		 //the relevant source data
        source.getCenter(srcVector);
        //System.out.println(srcVector);
        //the relevant detector data
        detector.getCenter(detectorCenterVector);
        //System.out.println(detectorCenterVector);
        detector.getOrientation(detectorOrientation);
        detector.getNormal(detectorNormal);
    
        //caching a numerator for calculation later
        sourceToDetector.sub(detectorCenterVector, srcVector);
        numerator = detectorNormal.dot(sourceToDetector);
	}
	
	public static SourceDetectorPair BuildDefault(Point3d sourceCenter,
	        Point3d detectorArrayCenter,
	        Point3d sdpCenter)
	{
	    DetectorArray d = 
	        DetectorArray.BuildDefault(detectorArrayCenter, sourceCenter);
	    Source s = 
	        Source.Build(sourceCenter, detectorArrayCenter);
		SourceDetectorPair sdp = new SourceDetectorPair(s, d, sdpCenter);
		sdp.giveChildrenParents(); 
		return sdp;
	}
	
	public static SourceDetectorPair BuildDefault(Point3d sourceCenter,
	        Point3d detectorArrayCenter,
	        Point3d sdpCenter,
	        int rows,
            int columns, 
            double pixelHeight,
            double pixelWidth)
	{
	    DetectorArray d = 
	        DetectorArray.Build(rows,
	        					  columns,
	        					  pixelHeight,
	        					  pixelWidth,
	        					  detectorArrayCenter, 
	        					  sourceCenter);
	        		//System.out.println(d);				
	    Source s = 
	        Source.Build(sourceCenter, detectorArrayCenter);
		SourceDetectorPair sdp = new SourceDetectorPair(s, d, sdpCenter);
		sdp.giveChildrenParents(); 
		return sdp;
	}
	
	
	public static SourceDetectorPair BuildDefault(double sourceDistance,
	        										double detectorDistance,
	        										int rows,
	        							            int columns, 
	        							            double pixelHeight,
	        							            double pixelWidth)
	{
	    Point3d sourceCenter =  new Point3d(-sourceDistance, 0, 0);
	    Point3d detectorCenter = new Point3d(detectorDistance, 0, 0);
	    Point3d sdpCenter = new Point3d(0, 0, 0);
	    SourceDetectorPair sdp = SourceDetectorPair.BuildDefault(
             sourceCenter,
              detectorCenter, 
              sdpCenter,
              rows,
              columns, 
              pixelHeight,
              pixelWidth);
	    //sdp.giveChildrenParents();
	    return sdp;
	}
	
	public static SourceDetectorPair BuildDefault(
			double sourceDistance,
			double detectorDistance) 
	{
		Point3d sourceCenter = new Point3d(-sourceDistance, 0, 0);
		Point3d detectorCenter = new Point3d(detectorDistance, 0, 0);
		Point3d sdpCenter = new Point3d(0, 0, 0);
		SourceDetectorPair sdp = SourceDetectorPair.BuildDefault(sourceCenter,
				detectorCenter, sdpCenter);
		// sdp.giveChildrenParents();
		return sdp;
	}
	
	public static SourceDetectorPair BuildDefault(double sourceDistance, 
			double detectorDistance,
			double rotation,
			int rows,
             int columns, 
             double pixelHeight,
             double pixelWidth)
	{    
	        SourceDetectorPair tempPair = SourceDetectorPair.BuildDefault(
	        		sourceDistance,
	        		detectorDistance,
	        		rows,
	        		columns,
	        		pixelHeight,
	        		pixelWidth);
	        
	        tempPair.rotateAboutNormal(rotation);
	       
	        
	        
	        TransformCreator tc = new TransformCreator();
	        tc.setAngle1(rotation);
	        Transform3D tr = tc.getTransform();
	        
	        Vector3d axis1 = tempPair.getInitAxis1();
	        tr.transform(axis1);
	        Vector3d axis2 = tempPair.getInitAxis2();
	        tr.transform(axis2);
	        Vector3d axis3 = tempPair.getInitAxis3();
	        tr.transform(axis3);
	        Vector3d basis1 = tempPair.getBasis1(); 
	        tr.transform(basis1);
	        Vector3d basis2 = tempPair.getBasis2();
	        tr.transform(basis2);
	        Vector3d basis3 = tempPair.getBasis3();
	        tr.transform(basis3);
	        
		    Point3d sourceCenter   = tempPair.getSource().getCenter();
		    Point3d detectorCenter = tempPair.getDetector().getCenter();
		    Point3d sdpCenter = new Point3d(0, 0, 0);
		    
	        SourceDetectorPair sdp = SourceDetectorPair.BuildDefault(
	             sourceCenter,
	              detectorCenter, 
	              sdpCenter,
	              rows,
	              columns,
	              pixelHeight,
	              pixelWidth);
	              
	        sdp.setInitAxis1(axis1);
	        sdp.setInitAxis2(axis2);
	        sdp.setInitAxis3(axis3);
	        sdp.setInitBasis1(basis1);
	        sdp.setInitBasis2(basis2);
	        sdp.setInitBasis3(basis3);
	        
//	        System.out.println(tempPair.getDetector().getTrajectory());
	       
//	        System.out.println("true");
//	       System.out.println(tempPair.getDetector().getOrientation());
	        //System.out.println(tempPair.getDetector().getAxis2());
//	        System.out.println("false");
//	        System.out.println(sdp.getDetector().getTrajectory());
//	        System.out.println(sdp.getDetector().getOrientation());
	     ///   System.out.println(sdp.getDetector().getAxis2());
	        
		    return sdp;
		
	}
	
	
	/**
	 * Its a hack in here- screwed up design early on and can not avoid this without major redesign. 
	 * @param sourceDistance
	 * @param detectorDistance
	 * @param rotation
	 * @return
	 */
    	public static SourceDetectorPair BuildDefault(double sourceDistance,
	        										double detectorDistance,
                                                    double rotation)
	{
        
        SourceDetectorPair tempPair = SourceDetectorPair.BuildDefault(sourceDistance, detectorDistance);
        tempPair.rotateAboutNormal(rotation);
       
        
        
        TransformCreator tc = new TransformCreator();
        tc.setAngle1(rotation);
        Transform3D tr = tc.getTransform();
        
        Vector3d axis1 = tempPair.getInitAxis1();
        tr.transform(axis1);
        Vector3d axis2 = tempPair.getInitAxis2();
        tr.transform(axis2);
        Vector3d axis3 = tempPair.getInitAxis3();
        tr.transform(axis3);
        Vector3d basis1 = tempPair.getBasis1(); 
        tr.transform(basis1);
        Vector3d basis2 = tempPair.getBasis2();
        tr.transform(basis2);
        Vector3d basis3 = tempPair.getBasis3();
        tr.transform(basis3);
        
	    Point3d sourceCenter   = tempPair.getSource().getCenter();
	    Point3d detectorCenter = tempPair.getDetector().getCenter();
	    Point3d sdpCenter = new Point3d(0, 0, 0);
	    
        SourceDetectorPair sdp = SourceDetectorPair.BuildDefault(
             sourceCenter,
              detectorCenter, 
              sdpCenter);
              
        sdp.setInitAxis1(axis1);
        sdp.setInitAxis2(axis2);
        sdp.setInitAxis3(axis3);
        sdp.setInitBasis1(basis1);
        sdp.setInitBasis2(basis2);
        sdp.setInitBasis3(basis3);
        
//        System.out.println(tempPair.getDetector().getTrajectory());
       
//        System.out.println("true");
//       System.out.println(tempPair.getDetector().getOrientation());
        //System.out.println(tempPair.getDetector().getAxis2());
//        System.out.println("false");
//        System.out.println(sdp.getDetector().getTrajectory());
//        System.out.println(sdp.getDetector().getOrientation());
     ///   System.out.println(sdp.getDetector().getAxis2());
        
	    return sdp;
	}
    
	
	public void rotateAboutNormal(double d)
	{
		this.rotateAboutInitAxis1(d);
	}
	
	public double getRotationAngle()
	{
	    return super.getRotation1();
	}
	
	public void setNormalAxis(Vector3d axis)
	{
		this.setInitAxis1(axis);
	}
	
	public Source getSource()
	{
		return this.source;
	}
	
	public void setSDPTranslation(double t1, double t2, double t3)
	{
	    this.setInitTranslation(t1, t2, t3);
	}
	
	public void setSDPRotation(double r1, double r2, double r3)
	{
	    this.rotateAboutInitAxis1(r1);
	    this.rotateAboutInitAxis2(r2);
	    this.rotateAboutInitAxis3(r3);
	}

	
	public DetectorArray getDetector()
	{
		return this.detector;
	}
	
	public String toString()
	{
	    String s = "";
	    s = s + "Source Detector Pair: " +"\n";
	    s = s + this.source.toString() + "\n";
	    s = s + this.detector.toString() +"\n";
	    return s;
	}
	//
	public void getIdealCentersOfProjection(Iterator fiducials, double[] projections, int offset)
    {
	        //the relevant source data
	        source.getCenter(srcVector);
	        //System.out.println(srcVector);
	        //the relevant detector data
	        detector.getCenter(detectorCenterVector);
	        //System.out.println(detectorCenterVector);
	        detector.getOrientation(detectorOrientation);
	        detector.getNormal(detectorNormal);
	    
	        //caching a numerator for calculation later
	        sourceToDetector.sub(detectorCenterVector, srcVector);
	        numerator = detectorNormal.dot(sourceToDetector);
	        
	    //iterating and projecting every fiducial
        int counter = offset;
	    while (fiducials.hasNext()) 
    		{	
	        //getting the attenuating point 
	        //System.out.println(srcVector);
	        TransformableObject to = (TransformableObject) fiducials.next();
    		    to.getCenter(attenuatingPoint);
    			
    			//sets the value of direction to the diference
    			//between attenuatingPoint and srcVector
    			this.direction.sub(attenuatingPoint, srcVector);
    			double denominator = detectorNormal.dot(direction);
    			
    			//sets the value of intersect to direction scaled by numerator/denominator + srcVector
    			intersect.scaleAdd(numerator/denominator, direction, srcVector);	
    			
    			//at this point, intersect holds the physical space position of the projection
    			//converting to continuous detector space
    			detector.physicalToDetectorContinuous2(intersect, detectorOrientation, projectedCenter);
    			
    			//putting the output into projections array
    			projections[counter] = projectedCenter.x;
       		counter++;
       		projections[counter] = projectedCenter.y;
       		counter++;
    		}
    }
	
	public static void main(String[] args)
	{
//		System.out.println(SourceDetectorPair.BuildDefault(10,10, 90));
		XRAYSystem xr = XRAYSystem.BuildDefault();
		xr.addDefaultSourceDetectorPair(100,100,0,10,10,1,1);
	}
}
