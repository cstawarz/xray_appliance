/* * Created on May 15, 2005 * */package Simulator;import javax.vecmath.Point2d;import javax.vecmath.Point3d;/** * @author Daniel Oreper * Created on May 15, 2005 */public class ReconStatStatUnknown extends OutputGenerator{    	/**	 * 	 * @param expectedSystem	 * @param actualValues	 * requires:	 * pass in an expectedSystem whose availableData per rotation is	 * equal to the size of actualValues. 	 * requires: 	 * expectedSystem must be centered- no deltas	 * requires: 	 * actualValues must be formatted in correct order-	 *	 *        * [pf0_x_d0_0,   //actual projection of fiducial0, x coordinate, onto detector 0, with no rotation        * pf0_y_d0_0,    //actual projection of fiducial0, y coordinate, onto detector 0, with no rotation        * pf1_x_d0_0,    //actual projection of fiducial1, x coordinate, onto detector 0, with no rotation           * pf1_y_d0_0,... //actual projection of fiducial1, y coordinate, onto detector 0, with no rotation        * pfn_x_d0_0,	 //actual projection of fiducialn, x coordinate, onto detector 0, with no rotation        * pfn_y_d0_0,	 //actual projection of fiducialn, y coordinate, onto detector 0, with no rotation        *         * pf0_x_d1_0,   //actual projection of fiducial0, x coordinate, onto detector 1, with no rotation        * pf0_y_d1_0,   //actual projection of fiducial0, y coordinate, onto detector 1, with no rotation        * pf1_x_d1_0,           * pf1_y_d1_0,...        * pfn_x_d1_0,        * pfn_y_d1_0,...        *         * pf0_x_dn_0,   //actual projection of fiducial0, x coordinate, onto detector n, with no rotation        * pf0_y_dn_0,   //actual projection of fiducial0, y coordinate, onto detector n, with no rotation        * pf1_x_dn_0,           * pf1_y_dn_0,...        * pfn_x_dn_0,        * pfn_y_dn_0]        */    public ReconStatStatUnknown(XRAYSystem expectedSystem, double[] actualValues)    {        super(expectedSystem, actualValues);        if (actualValues.length != expectedSystem.availableData(1))        {            throw new RuntimeException("Malformatted actualValues passed into go constructor");        }	    }        /**     * Format of X must be of the form:     * position1(f0),     * position2(f0),     * position3(f0),...     * position1(fn),      * position2(fn),     * position3(fn)]     *    * The output is of the form:        * [pf0_x_d0_0,   //projection of fiducial0, x coordinate, onto detector 0, with no rotation        * pf0_y_d0_0,    //projection of fiducial0, y coordinate, onto detector 0, with no rotation        * pf1_x_d0_0,    //projection of fiducial1, x coordinate, onto detector 0, with no rotation           * pf1_y_d0_0,... //projection of fiducial1, y coordinate, onto detector 0, with no rotation        * pfn_x_d0_0,	 //projection of fiducialn, x coordinate, onto detector 0, with no rotation        * pfn_y_d0_0,	 //projection of fiducialn, y coordinate, onto detector 0, with no rotation        *         * pf0_x_d1_0,   //projection of fiducial0, x coordinate, onto detector 1, with no rotation        * pf0_y_d1_0,   //projection of fiducial0, y coordinate, onto detector 1, with no rotation        * pf1_x_d1_0,           * pf1_y_d1_0,...        * pfn_x_d1_0,        * pfn_y_d1_0,...        *         * pf0_x_dn_0,   //projection of fiducial0, x coordinate, onto detector n, with no rotation        * pf0_y_dn_0,   //projection of fiducial0, y coordinate, onto detector n, with no rotation        * pf1_x_dn_0,           * pf1_y_dn_0,...        * pfn_x_dn_0,        * pfn_y_dn_0,...]        * */    public double[] calcExpected(double[] X)    {        if (X.length!= this.getRequiredInputSize())        {            throw new RuntimeException("wrong input length: " + X.length);        }                    for (int xIndex = 0; xIndex < X.length; xIndex = xIndex + 3)        {            int fiducialIndex = xIndex / 3;            //Point2d initPosition = expectedSystem.getFids().getFiducials().            double t1 = X[xIndex];            double t2 = X[xIndex + 1];            double t3 = X[xIndex + 2];                        try {                                        expectedSystem                    .setLightFiducialPosition(t1, t2, t3, fiducialIndex);            }            catch(RuntimeException rt)            {                System.out.println(expectedSystem);                System.out.println(t1);                System.out.println(t2);                System.out.println(t3);                System.out.println(fiducialIndex);                System.out.println("input vector to reconstatstatunkown is:");                OutputGenerator.printArray(X);                throw new RuntimeException("caught and thrown fid exception");                            }        }        try        {            expectedSystem.getIdealCentersOfProjection(expectedOutput, 0);        }        catch(RuntimeException e)        {            System.out.println(expectedSystem);            OutputGenerator.printArray(X);            throw e;        }            return (double[])this.expectedOutput.clone();    }        /**     *      * @effects: mutates this.expectedOutputX     */    private void calcExpected2(double[] X)    {        if (X.length!= this.getRequiredInputSize())        {            throw new RuntimeException("wrong input length: " + X.length);        }                    for (int xIndex = 0; xIndex < X.length; xIndex = xIndex + 3)        {            int fiducialIndex = xIndex / 3;            //Point2d initPosition = expectedSystem.getFids().getFiducials().            double t1 = X[xIndex];            double t2 = X[xIndex + 1];            double t3 = X[xIndex + 2];                        try {                                        expectedSystem                    .setLightFiducialPosition(t1, t2, t3, fiducialIndex);            }            catch(RuntimeException rt)            {                System.out.println(expectedSystem);                System.out.println(t1);                System.out.println(t2);                System.out.println(t3);                System.out.println(fiducialIndex);                OutputGenerator.printArray(X);                throw new RuntimeException("caught and thrown fid exception within recon stat stat unknown");                            }        }        try        {            expectedSystem.getIdealCentersOfProjection(expectedOutput, 0);        }        catch(RuntimeException e)        {            System.out.println(expectedSystem);            OutputGenerator.printArray(X);            throw e;        }    }        /**     * @return actualValues - expectedOutput,     */    public double[] calcF(double[] X)     {		if (!hasActualValues())		{			throw new RuntimeException("No actualValues with which to calcF");		}		calcExpected2(X); // sets this.expectedOutput		for (int i = 0; i < this.expectedOutput.length; i++)		{			this.fOutput[i] = actualValues[i] - this.expectedOutput[i];		}		return (double[]) this.fOutput.clone();	}        /**     * @return required size of the input to calcF, or calcExpected     */    public int getRequiredInputSize()    {          return (3 * expectedSystem.getNumberOfFiducials());      }        /**     *      * @return an input vector s.t. calcF(inputVector) ~= actualValues     */    public double[] generateGuess()    {    		System.out.println("generating guess");        double[] xGuess = getSampleInput();        if (!hasActualValues())        {            throw new RuntimeException("No data with which to generate guess");        }        //checking to make sure our actualValues are inBounds        if (!outputInBounds(actualValues))        {            //if bad data was created using simulation, simply fix the data.            if (this.isSimulatedData())            {                this.fixOutput(actualValues);            }            //if bad data is real data, throw exception            else            {                OutputGenerator.printArray(actualValues);                throw new RuntimeException(                        "Trying to generate a guess with data that is outside of reasonable bounds,"                                + "Check means by which data is inputted to outputSimulator");            }        }        //TODO: fix the recentering guess        //expectedSystem.getFids().reCenter();        //double[] xGuess = new double[24];               //System.out.println("guessing");       int numSDP = expectedSystem.getNumberOfSDP();       if (numSDP < 2)         {                throw new RuntimeException(                        "not enough data to generate init guess");            }            int dataPerArray = actualValues.length / numSDP;            // System.out.println(dataPerArray);            SourceDetectorPair sdp1 = expectedSystem.getSDP(0);            DetectorArray det1 = sdp1.getDetector();            Source src1 = sdp1.getSource();            SourceDetectorPair sdp2 = expectedSystem.getSDP(1);            DetectorArray det2 = sdp2.getDetector();            Source src2 = sdp2.getSource();            Point3d s1 = src1.getCenter();            Point3d d1 = new Point3d();            Point3d s2 = src2.getCenter();            Point3d d2 = new Point3d();            Point2d temp1 = new Point2d();            Point2d temp2 = new Point2d();            for (int i = 0; i < dataPerArray; i = i + 2)            {                double xIndex1 = actualValues[i];                double yIndex1 = actualValues[i + 1];                temp1.set(xIndex1, yIndex1);                d1.set(det1.detectorToPhysical(temp1));                double xIndex2 = actualValues[i + dataPerArray];                double yIndex2 = actualValues[i + 1 + dataPerArray];                temp2.set(xIndex2, yIndex2);                d2.set(det2.detectorToPhysical(temp2));                //System.out.println("guessing");                Point3d fidGuess = nearestIntersect(s1, d1, s2, d2); //finds                int fiducialIndex = i / 2;//                Point3d presentLocation = expectedSystem//                        .getFiducialLocation(fiducialIndex);                xGuess[3*fiducialIndex] =  fidGuess.x;                xGuess[3*fiducialIndex + 1] = fidGuess.y;                    xGuess[3*fiducialIndex + 2] = fidGuess.z;            }            return xGuess;    }        /**     * @return size of F when calcF is called     */    public int getRequiredOutputSize()    {        return expectedSystem.availableData(1);    }        /**     * @return a vector of zeros of the required input size     */    public double[] getSampleInput()    {        return new double[getRequiredInputSize()];    }        /**     * @return true if sure data is of the correct size to be an output from the simulator     * and has values that fit on the array - for example if the data includes a negative value, this method     * will return false, or if the data includes an element that is larger than the largest pixel index of the      * detector array     */    public boolean outputInBounds(double[] data)    {        return super.outputInBounds(data) && data.length == getRequiredOutputSize();    }   }