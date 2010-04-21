package Simulator;

public class CalibStatStatKnown extends OutputGenerator
{
       //offsets used for parsing inputs to the output generator
       private int firstOffset;
       private int secondOffset;
       private int thirdOffset;
      
       
       
       /**
   	 * 
   	 * @param expectedSystem
   	 * @param actualValues
   	 * requires:
   	 * pass in an expectedSystem whose availableData per rotation is
   	 * equal to the size of actualValues. 
   	 * requires: 
   	 * expectedSystem must be centered- no deltas
   	 * requires: 
   	 * actualValues must be formatted in correct order-
   	 *
   	 *
           * [pf0_x_d0_0,   //actual projection of fiducial0, x coordinate, onto detector 0, with no rotation
           * pf0_y_d0_0,    //actual projection of fiducial0, y coordinate, onto detector 0, with no rotation
           * pf1_x_d0_0,    //actual projection of fiducial1, x coordinate, onto detector 0, with no rotation   
           * pf1_y_d0_0,... //actual projection of fiducial1, y coordinate, onto detector 0, with no rotation
           * pfn_x_d0_0,	 //actual projection of fiducialn, x coordinate, onto detector 0, with no rotation
           * pfn_y_d0_0,	 //actual projection of fiducialn, y coordinate, onto detector 0, with no rotation
           * 
           * pf0_x_d1_0,   //actual projection of fiducial0, x coordinate, onto detector 1, with no rotation
           * pf0_y_d1_0,   //actual projection of fiducial0, y coordinate, onto detector 1, with no rotation
           * pf1_x_d1_0,   
           * pf1_y_d1_0,...
           * pfn_x_d1_0,
           * pfn_y_d1_0,...
           * 
           * pf0_x_dn_0,   //actual projection of fiducial0, x coordinate, onto detector n, with no rotation
           * pf0_y_dn_0,   //actual projection of fiducial0, y coordinate, onto detector n, with no rotation
           * pf1_x_dn_0,   
           * pf1_y_dn_0,...
           * pfn_x_dn_0,
           * pfn_y_dn_0]
           */
       public CalibStatStatKnown(XRAYSystem expectedSystem, double[] actualValues)
       {
           
           super(expectedSystem, actualValues);
          
           firstOffset = 3; //2 detector rotations + 1 detector translation
          
           //for every sdp beyond the first, there are
           //2 detector rotations Translation and 3 sdp translations + 3 sdp rotations = 8
           secondOffset = 
               firstOffset + (expectedSystem.getNumberOfSDP() - 1) * 9;
           
           //for the fiducial collection, there are 3 translations and 3 rotations that are unknown 
           thirdOffset = secondOffset + 6;
        
               if (actualValues.length != expectedSystem.availableData(1))
               {
                   System.out.println(expectedSystem.availableData(1));
                   System.out.println(actualValues.length);
                   throw new RuntimeException("Malformatted actualValues passed into go constructor");
               }
       }
       
       /**
        * Input format: 
        * fc = fiducial collection, s = source, d = detector, sdp = source detector pair
        * 
        * Format of X must be of the form:
        * [TranslationFromSource(d0),
        * RotationPolar(d0),
        * RotationAzimuthal(d0),...
        * 
        * TranslationFromSource(di) for 0<i<=n
        * RotationPolar(di),  
        * RotationAzimuthal(di),
        * RotationNormal(di), 
        * XTranslation(sdpi)
        * YTranslation(sdpi) 
        * ZTranslation(sdpi) 
        * RotationPolar(sdpi)
        * RotationAzimuthal(sdpi)....
        * 
        * TranslationFromSource(dn),
        * RotationPolar(dn),  
        * RotationAzimuthal(dn),
        * RotationNormal(dn), 
        * XTranslation(sdpn)
        * YTranslation(sdpn) 
        * ZTranslation(sdpn) 
        * RotationPolar(sdpn)
        * RotationAzimuthal(sdpn)....
        * 
        * XTranslation1(fc), 
        * YTranslation2(fc),
        * ZTranslation3(fc),
        * Rotation1(fc), 
        * Rotation2(fc),
        * Rotation3(fc)],
        */
       
       /**
        * calculates the output of the expectedSystem
        * 
        * the input is a set of perturbations
        * from the expected state of the system. 
        * 
        * 
        * 
        * For example, if the expectedSystem has its first sdp
        * at s = (70000,0,0) and d  = (-140000,0,0),
        * and if the first value of  X is 5000 and the rest of the values are 0,
        * the output will include a projection onto an sdp s.t.
        * s = (75000,0,0) and d = (-140000,0,0).
        * 
        * The output is of the form:
        * [pf0_x_d0_0,   //projection of fiducial0, x coordinate, onto detector 0, with no rotation
        * pf0_y_d0_0,    //projection of fiducial0, y coordinate, onto detector 0, with no rotation
        * pf1_x_d0_0,    //projection of fiducial1, x coordinate, onto detector 0, with no rotation   
        * pf1_y_d0_0,... //projection of fiducial1, y coordinate, onto detector 0, with no rotation
        * pfn_x_d0_0,	 //projection of fiducialn, x coordinate, onto detector 0, with no rotation
        * pfn_y_d0_0,	 //projection of fiducialn, y coordinate, onto detector 0, with no rotation
        * 
        * pf0_x_d1_0,   //projection of fiducial0, x coordinate, onto detector 1, with no rotation
        * pf0_y_d1_0,   //projection of fiducial0, y coordinate, onto detector 1, with no rotation
        * pf1_x_d1_0,   
        * pf1_y_d1_0,...
        * pfn_x_d1_0,
        * pfn_y_d1_0,...
        * 
        * pf0_x_dn_0,   //projection of fiducial0, x coordinate, onto detector n, with no rotation
        * pf0_y_dn_0,   //projection of fiducial0, y coordinate, onto detector n, with no rotation
        * pf1_x_dn_0,   
        * pf1_y_dn_0,...
        * pfn_x_dn_0,
        * pfn_y_dn_0,...
        * 
    */  
       public double[] calcExpected(double[] X)
       {
    	   		
           //detector (focal) ranslation and rotation, within the first 
           //detector pair
//    	   	   if (getRequiredInputSize()!=X.length)
//    	   	   {
//    	   		   throw new RuntimeException("input to CalibStatStatKnown is wrong size");
//    	   	   }
    	       double d0_t1 = X[0];
           expectedSystem.setDetectorTranslation(d0_t1, 0, 0, 0); // removes d0_t1 along focal axis
           double d0_r1 = X[1];
           double d0_r2 = X[2];
           expectedSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);
           
           //focal translation, detector rotation, sdp translation and rotation of detector pairs
           //beyond the second sdp
           for (int sdp = 1; sdp < expectedSystem.getNumberOfSDP(); sdp++)
           {
               double di_t1 = X[firstOffset + 9 * (sdp - 1)];
               expectedSystem.setDetectorTranslation(di_t1, 0, 0, sdp);
               
               double di_r1 = X[firstOffset + 9 * (sdp - 1) + 1];
               double di_r2 = X[firstOffset + 9 * (sdp - 1) + 2];
               double di_r3 = X[firstOffset + 9 * (sdp - 1) + 3];
               expectedSystem.setDetectorAngles(di_r1, di_r2, di_r3, sdp);
               
               double sdpi_t1 = X[firstOffset + 9 * (sdp - 1) + 4];
               double sdpi_t2 = X[firstOffset + 9 * (sdp - 1) + 5];
               double sdpi_t3 = X[firstOffset + 9 * (sdp - 1) + 6];
               expectedSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);
               
               double sdpi_r1 = X[firstOffset + 9 * (sdp - 1) + 7];
               double sdpi_r2 = X[firstOffset + 9 * (sdp - 1) + 8];
//               double sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];
               expectedSystem.setSDPRotation(sdpi_r1, 0, sdpi_r2, sdp);
           }
           
           //translations and rotations for all fiducials
          
           double fct1 = X[secondOffset];
           double fct2 = X[secondOffset + 1];
           double fct3 = X[secondOffset + 2];
           double fcr1  = X[secondOffset + 3];
           double fcr2  = X[secondOffset + 4];
           double fcr3  = X[secondOffset + 5];
           expectedSystem.getFids().fct1(fct1);
           expectedSystem.getFids().fct2(fct2);
           expectedSystem.getFids().fct3(fct3);
           expectedSystem.getFids().fcr1(fcr1);
           expectedSystem.getFids().fcr2(fcr2);
           expectedSystem.getFids().fcr3(fcr3);
           
      
           //harvesting data from the system
           try{
               //offset is 0 as this is the first set of projections
               expectedSystem.
               getIdealCentersOfProjection(expectedOutput, 0);
           }
           catch (RuntimeException re)
           {
               OutputGenerator.printArray(X);
               System.out.println(expectedSystem);
               throw(re);
           }
           return (double[]) this.expectedOutput.clone();
       }
     
   /**
    * same as calcExpected, but does not return an output, just modifies expectedOutput field,
    * and the expectedSystem
    * @param X
    */
   private void calcExpected2(double[] X)
   {
       double d0_t1 = X[0];
       expectedSystem.setDetectorTranslation(d0_t1, 0, 0, 0);
       double d0_r1 = X[1];
       double d0_r2 = X[2];
       expectedSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);
       
       //focal translation, detector rotation, sdp translation and rotation of detector pairs
       //beyond the second sdp
       for (int sdp = 1; sdp < expectedSystem.getNumberOfSDP(); sdp++)
       {
           double di_t1 = X[firstOffset + 9 * (sdp - 1)];
           expectedSystem.setDetectorTranslation(di_t1, 0, 0, sdp);
           
           double di_r1 = X[firstOffset + 9 * (sdp - 1) + 1];
           double di_r2 = X[firstOffset + 9 * (sdp - 1) + 2];
           double di_r3 = X[firstOffset + 9 * (sdp - 1) + 3];
           expectedSystem.setDetectorAngles(di_r1, di_r2, di_r3, sdp);
           
           double sdpi_t1 = X[firstOffset + 9 * (sdp - 1) + 4];
           double sdpi_t2 = X[firstOffset + 9 * (sdp - 1) + 5];
           double sdpi_t3 = X[firstOffset + 9 * (sdp - 1) + 6];
           expectedSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);
           
           double sdpi_r1 = X[firstOffset + 9 * (sdp - 1) + 7];
           double sdpi_r2 = X[firstOffset + 9 * (sdp - 1) + 8];
//           double sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];
           expectedSystem.setSDPRotation(sdpi_r1, 0, sdpi_r2, sdp);
       }
       
       //translations and rotations for all fiducials
      
       double fct1 = X[secondOffset];
       double fct2 = X[secondOffset + 1];
       double fct3 = X[secondOffset + 2];
       double fcr1  = X[secondOffset + 3];
       double fcr2  = X[secondOffset + 4];
       double fcr3  = X[secondOffset + 5];
       expectedSystem.getFids().fct1(fct1);
       expectedSystem.getFids().fct2(fct2);
       expectedSystem.getFids().fct3(fct3);
       expectedSystem.getFids().fcr1(fcr1);
       expectedSystem.getFids().fcr2(fcr2);
       expectedSystem.getFids().fcr3(fcr3);
       
  
       //harvesting data from the system
       try{
           //offset is 0 as this is the first set of projections
           expectedSystem.
           getIdealCentersOfProjection(expectedOutput, 0);
       }
       catch (RuntimeException re)
       {
           OutputGenerator.printArray(X);
           System.out.println(expectedSystem);
           throw(re);
       }
   }
        
    /**
    * @return (actualValues - expectedOutput), 
    */
   public double[] calcF(double[] X)
   {

       if (!hasActualValues())
       {
           throw new RuntimeException("No actualValues with which to calcF");
       }

       calcExpected2(X);
       for (int i = 0; i < this.expectedOutput.length; i++)
       {
           this.fOutput[i] = actualValues[i] - this.expectedOutput[i];
       }
       return (double[]) this.fOutput.clone();
   }

   /**
    * @return size of X that must be passed in to calcF
    */
   public int getRequiredInputSize()
   {
       return thirdOffset;
   }

   /**
    * @return size of F when calcF is called
    */
   public int getRequiredOutputSize()
   {
       return expectedSystem.availableData(1);
   }

   /**
    * @return a vector of zeros of the required input size
    */
   public double[] getSampleInput()
   {
       double[] xGuess = new double[getRequiredInputSize()];
       return xGuess;
   }

   /**
    * @return true if sure data is of the correct size to be an output from the simulator
    * and has values that fit on the array - for example if the data includes a negative value, this method
    * will return false, or if the data includes an element that is larger than the largest pixel index of the 
    * detector array
    */
   public boolean outputInBounds(double[] data)
   {
       return super.outputInBounds(data) //checks individual values in the data
              && data.length == getRequiredOutputSize(); //checks to make sure we have right size
   }
}

