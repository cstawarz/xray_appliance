/*  * ParamGuesser.java * Created on Jul 16, 2005 * By Daniel Oreper  */package Simulator;import javax.vecmath.Point3d;import javax.vecmath.Vector3d;public class ParamGuesser extends OutputGenerator{        private int firstOffset;    private int secondOffset;    private int thirdOffset;    private double rotationSpread;        public ParamGuesser(XRAYSystem expectedSystem, double[] actualValues)    {    	        super(expectedSystem, actualValues, false);        this.rotationSpread = rotationSpread;//        OutputGenerator.printArray(actualValues);                if (actualValues.length != expectedSystem.getNumberOfFiducials()*3         		+ 7 + (expectedSystem.getNumberOfSDP()-1)*12)        {            System.out.println("actual values are:");            OutputGenerator.printArray(actualValues);            throw new RuntimeException("malformatted actualValues");        }        firstOffset = 3; //2 detector rotations + 1 detector translation                 //for every sdp beyond the first, there are         //2 detector rotations and 3 sdp translations + 3 sdp rotations = 8         secondOffset =              firstOffset + (expectedSystem.getNumberOfSDP() - 1) * 9;                  //for every fiducial, there are 3 translations that are unknown          thirdOffset = secondOffset + 6;            }    public double[] calcExpected(double[] X)   {       //detector translation and rotation, within the first        //detector pair       double d0_t1 = X[0];       expectedSystem.setDetectorTranslation(d0_t1, 0, 0, 0);       double d0_r1 = X[1];       double d0_r2 = X[2];       expectedSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);              //focal translation, detector rotation, sdp translation and rotation of detector pairs       //beyond the second sdp       for (int sdp = 1; sdp < expectedSystem.getNumberOfSDP(); sdp++)       {           double di_t1 = X[firstOffset + 9 * (sdp - 1)];           expectedSystem.setDetectorTranslation(di_t1, 0, 0, sdp);                      double di_r1 = X[firstOffset + 9 * (sdp - 1) + 1];           double di_r2 = X[firstOffset + 9 * (sdp - 1) + 2];           double di_r3 = X[firstOffset + 9 * (sdp - 1) + 3];           expectedSystem.setDetectorAngles(di_r1, di_r2, di_r3, sdp);                      double sdpi_t1 = X[firstOffset + 9 * (sdp - 1) + 4];           double sdpi_t2 = X[firstOffset + 9 * (sdp - 1) + 5];            double sdpi_t3 = X[firstOffset + 9 * (sdp - 1) + 6];           expectedSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);                      double sdpi_r1 = X[firstOffset + 9 * (sdp - 1) + 7];// + rotationSpread;           double sdpi_r2 = X[firstOffset + 9 * (sdp - 1) + 8];//hack to center variable at 0!;//           double sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];           expectedSystem.setSDPRotation(sdpi_r1, 0, sdpi_r2, sdp);       }              //translations and rotations for all fiducials             double fct1 = X[secondOffset];       double fct2 = X[secondOffset + 1];       double fct3 = X[secondOffset + 2];       double fcr1  = X[secondOffset + 3];       double fcr2  = X[secondOffset + 4];       double fcr3  = X[secondOffset + 5];       expectedSystem.getFids().fct1(fct1);       expectedSystem.getFids().fct2(fct2);       expectedSystem.getFids().fct3(fct3);       expectedSystem.getFids().fcr1(fcr1);       expectedSystem.getFids().fcr2(fcr2);       expectedSystem.getFids().fcr3(fcr3);                      //double[] output = new double[getRequiredOutputSize()];      expectedOutput[0] = expectedSystem.getDetectorLocation(0).x;      Vector3d horz0 = expectedSystem.getSDP(0).getDetector().getOrientation().getB1();      expectedOutput[1] = horz0.x;      expectedOutput[2] = horz0.y;      expectedOutput[3] = horz0.z;      Vector3d vert0 = expectedSystem.getSDP(0).getDetector().getOrientation().getB2();      expectedOutput[4] = vert0.x;      expectedOutput[5] = vert0.y;      expectedOutput[6] = vert0.z;            int offset = 6;      for  (int i = 1; i < expectedSystem.getNumberOfSDP(); i++)      {    	  Point3d srcCenter = expectedSystem.getSourceLocation(i);      expectedOutput[offset + (i-1)*12 + 1] = srcCenter.x;      expectedOutput[offset + (i-1)*12 + 2] = srcCenter.y;      expectedOutput[offset + (i-1)*12 + 3] = srcCenter.z;      Point3d detCenter = expectedSystem.getDetectorLocation(i);      expectedOutput[offset + (i-1)*12 + 4] = detCenter.x;      expectedOutput[offset + (i-1)*12 + 5] = detCenter.y;      expectedOutput[offset + (i-1)*12 + 6] = detCenter.z;      Vector3d horz = expectedSystem.getSDP(i).getDetector().getOrientation().getB1();      expectedOutput[offset + (i-1)*12 + 7] = horz.x;      expectedOutput[offset + (i-1)*12 + 8] = horz.y;      expectedOutput[offset + (i-1)*12 + 9] = horz.z;      Vector3d vert = expectedSystem.getSDP(i).getDetector().getOrientation().getB2();      expectedOutput[offset + (i-1)*12 + 10] = vert.x;      expectedOutput[offset + (i-1)*12 + 11] = vert.y;      expectedOutput[offset + (i-1)*12 + 12] = vert.z;      }      int offset2 = 6 + (expectedSystem.getNumberOfSDP()-1)*12;      for (int i = 0; i<expectedSystem.getNumberOfFiducials(); i++)      {          Point3d fidLocation = expectedSystem.getFiducialLocation(i);          expectedOutput[offset2 + 3*i + 1] = fidLocation.x;          expectedOutput[offset2 + 3*i + 2] = fidLocation.y;          expectedOutput[offset2 + 3*i + 3] = fidLocation.z;      }      return (double[])expectedOutput.clone();  }	   public void calcExpected2(double[] X)   {    //detector translation and rotation, within the first     //detector pair    double d0_t1 = X[0];    expectedSystem.setDetectorTranslation(d0_t1, 0, 0, 0);    double d0_r1 = X[1];    double d0_r2 = X[2];    expectedSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);        //focal translation, detector rotation, sdp translation and rotation of detector pairs    //beyond the second sdp    for (int sdp = 1; sdp < expectedSystem.getNumberOfSDP(); sdp++)    {        double di_t1 = X[firstOffset + 9 * (sdp - 1)];        expectedSystem.setDetectorTranslation(di_t1, 0, 0, sdp);                double di_r1 = X[firstOffset + 9 * (sdp - 1) + 1];        double di_r2 = X[firstOffset + 9 * (sdp - 1) + 2];        double di_r3 = X[firstOffset + 9 * (sdp - 1) + 3];        expectedSystem.setDetectorAngles(di_r1, di_r2, di_r3, sdp);                double sdpi_t1 = X[firstOffset + 9 * (sdp - 1) + 4];        double sdpi_t2 = X[firstOffset + 9 * (sdp - 1) + 5];         double sdpi_t3 = X[firstOffset + 9 * (sdp - 1) + 6];        expectedSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);                double sdpi_r1 = X[firstOffset + 9 * (sdp - 1) + 7];// + rotationSpread;        double sdpi_r2 = X[firstOffset + 9 * (sdp - 1) + 8];//hack to center variable at 0!;//        double sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];        expectedSystem.setSDPRotation(sdpi_r1, 0, sdpi_r2, sdp);    }        //translations and rotations for all fiducials       double fct1 = X[secondOffset];    double fct2 = X[secondOffset + 1];    double fct3 = X[secondOffset + 2];    double fcr1  = X[secondOffset + 3];    double fcr2  = X[secondOffset + 4];    double fcr3  = X[secondOffset + 5];    expectedSystem.getFids().fct1(fct1);    expectedSystem.getFids().fct2(fct2);    expectedSystem.getFids().fct3(fct3);    expectedSystem.getFids().fcr1(fcr1);    expectedSystem.getFids().fcr2(fcr2);    expectedSystem.getFids().fcr3(fcr3);             //double[] output = new double[getRequiredOutputSize()];   expectedOutput[0] = expectedSystem.getDetectorLocation(0).x;   Vector3d horz0 = expectedSystem.getSDP(0).getDetector().getOrientation().getB1();   expectedOutput[1] = horz0.x;   expectedOutput[2] = horz0.y;   expectedOutput[3] = horz0.z;   Vector3d vert0 = expectedSystem.getSDP(0).getDetector().getOrientation().getB2();   expectedOutput[4] = vert0.x;   expectedOutput[5] = vert0.y;   expectedOutput[6] = vert0.z;      int offset = 6;   for  (int i = 1; i < expectedSystem.getNumberOfSDP(); i++)   { 	  Point3d srcCenter = expectedSystem.getSourceLocation(i);   expectedOutput[offset + (i-1)*12 + 1] = srcCenter.x;   expectedOutput[offset + (i-1)*12 + 2] = srcCenter.y;   expectedOutput[offset + (i-1)*12 + 3] = srcCenter.z;   Point3d detCenter = expectedSystem.getDetectorLocation(i);   expectedOutput[offset + (i-1)*12 + 4] = detCenter.x;   expectedOutput[offset + (i-1)*12 + 5] = detCenter.y;   expectedOutput[offset + (i-1)*12 + 6] = detCenter.z;   Vector3d horz = expectedSystem.getSDP(i).getDetector().getOrientation().getB1();   expectedOutput[offset + (i-1)*12 + 7] = horz.x;   expectedOutput[offset + (i-1)*12 + 8] = horz.y;   expectedOutput[offset + (i-1)*12 + 9] = horz.z;   Vector3d vert = expectedSystem.getSDP(i).getDetector().getOrientation().getB2();   expectedOutput[offset + (i-1)*12 + 10] = vert.x;   expectedOutput[offset + (i-1)*12 + 11] = vert.y;   expectedOutput[offset + (i-1)*12 + 12] = vert.z;   }   int offset2 = 6 + (expectedSystem.getNumberOfSDP()-1)*12;      for (int i = 0; i<expectedSystem.getNumberOfFiducials(); i++)   {       Point3d fidLocation = expectedSystem.getFiducialLocation(i);       expectedOutput[offset2 + 3*i + 1] = fidLocation.x;       expectedOutput[offset2 + 3*i + 2] = fidLocation.y;       expectedOutput[offset2 + 3*i + 3] = fidLocation.z;   }  }	     public int getRequiredOutputSize()  {      return 3*expectedSystem.getNumberOfFiducials() +       7 +       (expectedSystem.getNumberOfSDP()-1)*12;  }    public int getRequiredInputSize()  {      return 6 + 12*(expectedSystem.getNumberOfSDP()-1);  }    public double[] calcF(double[] X)  {      if (!hasActualValues())      {          throw new RuntimeException("No actualValues with which to calcF");      }      calcExpected2(X);      for (int i = 0; i < this.expectedOutput.length; i++)      {          this.fOutput[i] = actualValues[i] - this.expectedOutput[i];          if(((i>=6)&&(i<=11))||((i>=13)&&(i<=18)))          {              this.fOutput[i] = 10*this.fOutput[i];          }      }      return (double[]) this.fOutput.clone();  }    public double[] generateGuess()  {      return new double[this.getRequiredInputSize()];  }    public double[] getSampleInput()  {      return generateGuess();  }      }