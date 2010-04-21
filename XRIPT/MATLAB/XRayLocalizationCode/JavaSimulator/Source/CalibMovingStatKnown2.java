/* * Created on Jul 7, 2005 * */package Simulator;import java.io.BufferedWriter;import java.io.File;import java.io.FileWriter;import java.text.NumberFormat;import javax.vecmath.Point2d;import javax.vecmath.Point3d;public class CalibMovingStatKnown2 extends OutputGenerator{//  TODO: find a way to avoid cloning output buffer        //offsets used for parsing inputs to the output generator        private int firstOffset;        private int secondOffset;        private int thirdOffset;        private int fourthOffset;        private int rotations;        private double[] expectedRotations;        //private double maxPixelError; //initiallySet to impossible large maxPixelError        //private ArrayList fiducialCollections;                        public CalibMovingStatKnown2(XRAYSystem expectedSystem, double[] expectedRotations,double[] actualValues)        {                                  super(expectedSystem, actualValues);            rotations = 0;            if (expectedRotations!=null)            {                rotations = expectedRotations.length;            }                       firstOffset = 3; //2 detector rotations + 1 detector translation                       //for every sdp beyond the first, there are            //2 detector rotations Translation and 3 sdp translations + 3 sdp rotations = 8            secondOffset =                 firstOffset + (expectedSystem.getNumberOfSDP() - 1) * 9;                        //for every fiducial, there are 3 translations that are unknown             thirdOffset = secondOffset + 6;                        //for every rotary stage (1), there are 3 unknown position variables,             //and 2 varibles to determine the axis of the rotary stage            fourthOffset = thirdOffset + 5;                         if (actualValues.length != expectedSystem.availableData(rotations+1))                {                    System.out.println(expectedSystem.availableData(expectedRotations.length+1));                    System.out.println(actualValues.length);                    throw new RuntimeException("Malformatted actualValues passed into go constructor");                }                    //maxPixelError = 1000;            this.expectedRotations = expectedRotations;        }                /**         * Input format:          * f = fiducial, s = source, d = detector, stage = rotary stage         *          * Format of X must be of the form:         * [Translation1(s0),         * Translation1(s1),         * Translation2(s1),         * Translation1(d1),         * Translation2(d1),         * Translation3(d1),          * Translation1(s_i) //all i>=2         * Translation2(s_i)         * Translation3(s_i)         * Translation1(d_i)         * Translation2(d_i)         * Translation3(d_i)...         * Translation1(s_n)          * Translation2(s_n)         * Translation3(s_n)         * Translation1(d_n)         * Translation2(d_n)         * Translation3(d_n)...         * RotationNormal(d_i), //for i>=0         * RotationPolar(d_i),         * RotationAzimuthal(d_i),...         * RotationNormal(dn),         * RotationPolar(dn),         * RotationAzimuthal(dn),         * Translation1(f_i), //for i>=0         * Translation2(f_i),         * Translation3(f_i),...         * Translation1(f_n),          * Translation2(f_n),         * Translation3(f_n)],         * Stage rotation Point OffsetX,         * Stage rotation Point OffsetY,         * Stage rotation Point OffsetZ,         * polar rotation of rotation axis,          * azimuthal rotation of rotation axis,         * rotation 0 delta,...         * rotation n delta          */                /**         * calculates the output of the expectedSystem after rotating          * a rotary stage through expected rotations given some set of perturbations,         * and projecting onto every detector array.         *          * the input is a set of source and detector translation perturbations         * from their expected state, detector angle perturbations,         * fiducial perturbations (from the point (0,0,0)- these are from (0,0,0)         * as an optimization for speed to avoid any subtractions or additions, as the number         * of fiducials may be large.           *          * rotation point pertrubations (from the point 0,0,0)         * rotation axis pertubations, and rotation perturbations.         *          *          *          * For example, if the expectedSystem has its first sdp         * at s = (70000,0,0) and d  = (-140000,0,0),         * and if the first value of  X is 5000 and the rest of the values are 0,         * the output will include a projection onto an sdp s.t.         * s = (75000,0,0) and d = (-140000,0,0).         *          * The output is of the form:         * [pf0_x_d0_0,   //projection of fiducial0, x coordinate, onto detector 0, with no rotation         * pf0_y_d0_0,    //projection of fiducial0, y coordinate, onto detector 0, with no rotation         * pf1_x_d0_0,    //projection of fiducial1, x coordinate, onto detector 0, with no rotation            * pf1_y_d0_0,... //projection of fiducial1, y coordinate, onto detector 0, with no rotation         * pfn_x_d0_0,	 //projection of fiducialn, x coordinate, onto detector 0, with no rotation         * pfn_y_d0_0,	 //projection of fiducialn, y coordinate, onto detector 0, with no rotation         *          * pf0_x_d1_0,   //projection of fiducial0, x coordinate, onto detector 1, with no rotation         * pf0_y_d1_0,   //projection of fiducial0, y coordinate, onto detector 1, with no rotation         * pf1_x_d1_0,            * pf1_y_d1_0,...         * pfn_x_d1_0,         * pfn_y_d1_0,...         *          * pf0_x_dn_0,   //projection of fiducial0, x coordinate, onto detector n, with no rotation         * pf0_y_dn_0,   //projection of fiducial0, y coordinate, onto detector n, with no rotation         * pf1_x_dn_0,            * pf1_y_dn_0,...         * pfn_x_dn_0,         * pfn_y_dn_0,...         *          * pf0_x_d0_rot0,   //projection of fiducial0, x coordinate, onto detector 0, with an actual rotation of rot0         * pf0_y_d0_rot0,   //projection of fiducial0, y coordinate, onto detector 0, with an actual rotation of rot0         * pf1_x_d0_rot0,                * pf1_y_d0_rot0,...          * pfn_x_d0_rot0,	          * pfn_y_d0_rot0,	          *          * pf0_x_d1_rot0,   //projection of fiducial0, x coordinate, onto detector 1, with an actual rotation of rot0         * pf0_y_d1_rot0,   //projection of fiducial0, y coordinate, onto detector 1, with an actual rotation of rot0         * pf1_x_d1_rot0,            * pf1_y_d1_rot0,...         * pfn_x_d1_rot0,         * pfn_y_d1_rot0,...         *          * pf0_x_dn_rot0,   //projection of fiducial0, x coordinate, onto detector n, with an actual rotation of rot0         * pf0_y_dn_rot0,   //projection of fiducial0, y coordinate, onto detector n, with an acutal rotation of rot0         * pf1_x_dn_rot0,            * pf1_y_dn_rot0,...         * pfn_x_dn_rot0,         * pfn_y_dn_rot0,...         *          * pf0_x_d0_rot0,   //projection of fiducial0, x coordinate, onto detector 0, with an actual rotation of rotn         * pf0_y_d0_rot0,   //projection of fiducial0, y coordinate, onto detector 0, with an actual rotation of rotn         * pf1_x_d0_rot0,                * pf1_y_d0_rot0,...          * pfn_x_d0_rot0,	          * pfn_y_d0_rot0,	          *          * pf0_x_d1_rot0,   //projection of fiducial0, x coordinate, onto detector 1, with an actual rotation of rotn         * pf0_y_d1_rot0,   //projection of fiducial0, y coordinate, onto detector 1, with an actual rotation of rotn         * pf1_x_d1_rot0,            * pf1_y_d1_rot0,...         * pfn_x_d1_rot0,         * pfn_y_d1_rot0,...         *          * pf0_x_dn_rot0,   //projection of fiducial0, x coordinate, onto detector n, with an actual rotation of rotn         * pf0_y_dn_rot0,   //projection of fiducial0, y coordinate, onto detector n, with an acutal rotation of rotn         * pf1_x_dn_rot0,            * pf1_y_dn_rot0,...         * pfn_x_dn_rot0,         * pfn_y_dn_rot0,...         *          *          * An important thing to note about the output is that it includes         * the projection of fiducials on a rotary stage that has not been rotated, and then appends          * the projection of the fiducials at every rotation (rot0...rotn).          */        public double[] calcExpected(double[] X)        {            //detector translation and rotation, within the first             //detector pair            double d0_t1 = X[0];            expectedSystem.setDetectorTranslation(d0_t1, 0, 0, 0);            double d0_r1 = X[1];            double d0_r2 = X[2];            expectedSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);                        //focal translation, detector rotation, sdp translation and rotation of detector pairs            //beyond the second sdp            for (int sdp = 1; sdp < expectedSystem.getNumberOfSDP(); sdp++)            {                double di_t1 = X[firstOffset + 9 * (sdp - 1)];                expectedSystem.setDetectorTranslation(di_t1, 0, 0, sdp);                                double di_r1 = X[firstOffset + 9 * (sdp - 1) + 1];                double di_r2 = X[firstOffset + 9 * (sdp - 1) + 2];                expectedSystem.setDetectorAngles(di_r1, di_r2, 0, sdp);                                double sdpi_t1 = X[firstOffset + 9 * (sdp - 1) + 3];                double sdpi_t2 = X[firstOffset + 9 * (sdp - 1) + 4];                double sdpi_t3 = X[firstOffset + 9 * (sdp - 1) + 5];                expectedSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);                                double sdpi_r1 = X[firstOffset + 9 * (sdp - 1) + 6];                double sdpi_r2 = X[firstOffset + 9 * (sdp - 1) + 7];                double sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];                expectedSystem.setSDPRotation(sdpi_r1, sdpi_r2, sdpi_r3, sdp);            }                        //translations and rotations for all fiducials                       double fct1 = X[secondOffset];            double fct2 = X[secondOffset + 1];            double fct3 = X[secondOffset + 2];            double fcr1  = X[secondOffset + 3];            double fcr2  = X[secondOffset + 4];            double fcr3  = X[secondOffset + 5];            expectedSystem.getFids().fct1(fct1);            expectedSystem.getFids().fct2(fct2);            expectedSystem.getFids().fct3(fct3);            expectedSystem.getFids().fcr1(fcr1);            expectedSystem.getFids().fcr2(fcr2);            expectedSystem.getFids().fcr3(fcr3);                                    //translateing the rotary stage, and setting its axis            double staget1 = X[thirdOffset];            double staget2 = X[thirdOffset + 1];            double staget3 = X[thirdOffset + 2];            //TODO: fix this call to avoid getFids()            expectedSystem.getFids().t1(staget1);            expectedSystem.getFids().t2(staget2);            expectedSystem.getFids().t3(staget3);                        //axis            double polar = X[thirdOffset + 3];            double azimuthal = X[thirdOffset + 4];            expectedSystem.getFids().setIdealRotationAxis(polar, azimuthal);                        //harvesting data from the system            try{                expectedSystem.rotateFiducials(0);                //offset is 0 as this is the first set of projections                expectedSystem.                getIdealCentersOfProjection(expectedOutput, 0);            }            catch (RuntimeException re)            {                OutputGenerator.printArray(X);                System.out.println(expectedSystem);                throw(re);            }            for(int rotationIndex = 0;             rotationIndex < rotations;            rotationIndex++)            {                double rot = expectedRotations[rotationIndex] + X[fourthOffset + rotationIndex];                expectedSystem.rotateFiducials(rot);                //aaccumulating projections from more rotations and placeing them into expectedOutput                expectedSystem.getIdealCentersOfProjection                (expectedOutput, (rotationIndex+1)*expectedSystem.availableData((1)));            }            return (double[]) this.expectedOutput.clone();        }            public void calcExpected2(double[] X)    {        double d0_t1 = X[0];        expectedSystem.setDetectorTranslation(d0_t1, 0, 0, 0);        double d0_r1 = X[1];        double d0_r2 = X[2];        expectedSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);                //focal translation, detector rotation, sdp translation and rotation of detector pairs        //beyond the second sdp        for (int sdp = 1; sdp < expectedSystem.getNumberOfSDP(); sdp++)        {            double di_t1 = X[firstOffset + 9 * (sdp - 1)];            expectedSystem.setDetectorTranslation(di_t1, 0, 0, sdp);                        double di_r1 = X[firstOffset + 9 * (sdp - 1) + 1];            double di_r2 = X[firstOffset + 9 * (sdp - 1) + 2];            expectedSystem.setDetectorAngles(di_r1, di_r2, 0, sdp);                        double sdpi_t1 = X[firstOffset + 9 * (sdp - 1) + 3];            double sdpi_t2 = X[firstOffset + 9 * (sdp - 1) + 4];            double sdpi_t3 = X[firstOffset + 9 * (sdp - 1) + 5];            expectedSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);                        double sdpi_r1 = X[firstOffset + 9 * (sdp - 1) + 6];            double sdpi_r2 = X[firstOffset + 9 * (sdp - 1) + 7];            double sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];            expectedSystem.setSDPRotation(sdpi_r1, sdpi_r2, sdpi_r3, sdp);        }                //translations and rotations for all fiducials               double fct1 = X[secondOffset];        double fct2 = X[secondOffset + 1];        double fct3 = X[secondOffset + 2];        double fcr1  = X[secondOffset + 3];        double fcr2  = X[secondOffset + 4];        double fcr3  = X[secondOffset + 5];        expectedSystem.getFids().fct1(fct1);        expectedSystem.getFids().fct2(fct2);        expectedSystem.getFids().fct3(fct3);        expectedSystem.getFids().fcr1(fcr1);        expectedSystem.getFids().fcr2(fcr2);        expectedSystem.getFids().fcr3(fcr3);                        //translateing the rotary stage, and setting its axis       double staget1 = X[thirdOffset];        double staget2 = X[thirdOffset + 1];        double staget3 = X[thirdOffset + 2];        //TODO: fix this call to avoid getFids()        expectedSystem.getFids().t1(staget1);        expectedSystem.getFids().t2(staget2);        expectedSystem.getFids().t3(staget3);                //axis        double polar = X[thirdOffset + 3];        double azimuthal = X[thirdOffset + 4];        expectedSystem.getFids().setIdealRotationAxis(polar, azimuthal);                //harvesting data from the system        try{            expectedSystem.rotateFiducials(0);            //offset is 0 as this is the first set of projections            expectedSystem.            getIdealCentersOfProjection(expectedOutput, 0);        }        catch (RuntimeException re)        {            OutputGenerator.printArray(X);            System.out.println(expectedSystem);            throw(re);        }        for(int rotationIndex = 0;         rotationIndex < rotations;        rotationIndex++)        {            double rot = expectedRotations[rotationIndex] + X[fourthOffset + rotationIndex];            expectedSystem.rotateFiducials(rot);            //aaccumulating projections from more rotations and placeing them into expectedOutput            expectedSystem.getIdealCentersOfProjection            (expectedOutput, (rotationIndex+1)*expectedSystem.availableData((1)));        }    }                 /**     * @requires: We have a valid upper bound on maxPixelError! very     *            important     * @return actualValues - expectedOutput, multiplying by 10 if the     *         expected output is out of bounds.     */    public double[] calcF(double[] X)    {        if (!hasActualValues())        {            throw new RuntimeException("No actualValues with which to calcF");        }        //TODO: get rid of this check and move it somewhere else- too        // costly perhaps        //            if (!outputInBounds(actualValues))        //            {        //                throw new RuntimeException(        //                        "Trying to calculate F with data that is out of bounds.");        //            }        calcExpected2(X);        for (int i = 0; i < this.expectedOutput.length; i++)        {            this.fOutput[i] = actualValues[i] - this.expectedOutput[i];        }        return (double[]) this.fOutput.clone();    }    public int getRequiredInputSize()    {        return fourthOffset + rotations;    }    public double[] generateGuess()    {        //System.out.println("guessing");        double[] xGuess = getSampleInput();        //offset at which we need to change the sample input to hold        //fiducial position guesses        int sampleInputOffset = secondOffset;        if (!hasActualValues())        {            throw new RuntimeException("No data with which to generate guess");        }        //checking to make sure our actualValues are inBounds        if (!outputInBounds(actualValues))        {            throw new RuntimeException(                    "Trying to generate a guess with data that is outside of reasonable bounds,"                            + "Check means by which data is inputted to outputSimulator");        }//        expectedSystem.reCenter();        //System.out.println("guessing");        int numSDP = expectedSystem.getNumberOfSDP();        if (numSDP < 2)        {            throw new RuntimeException("not enough data to generate init guess");        }        int dataPerArray = expectedSystem.availableData(1) / numSDP;        // System.out.println(dataPerArray);        SourceDetectorPair sdp1 = expectedSystem.getSDP(0);        DetectorArray det1 = sdp1.getDetector();        Source src1 = sdp1.getSource();        SourceDetectorPair sdp2 = expectedSystem.getSDP(1);        DetectorArray det2 = sdp2.getDetector();        Source src2 = sdp2.getSource();        Point3d s1 = src1.getCenter();        Point3d d1 = new Point3d();        Point3d s2 = src2.getCenter();        Point3d d2 = new Point3d();        Point2d temp1 = new Point2d();        Point2d temp2 = new Point2d();        for (int i = 0; i < dataPerArray; i = i + 2)        {            double xIndex1 = actualValues[i];            double yIndex1 = actualValues[i + 1];            temp1.set(xIndex1, yIndex1);            //System.out.println(temp1);            d1.set(det1.detectorToPhysical(temp1));            double xIndex2 = actualValues[i + dataPerArray];            double yIndex2 = actualValues[i + 1 + dataPerArray];            temp2.set(xIndex2, yIndex2);            //System.out.println(temp2);            d2.set(det2.detectorToPhysical(temp2));            //System.out.println("guessing");            //System.out.println(s1);            //System.out.println(s2);            Point3d fidGuess = nearestIntersect(s1, d1, s2, d2); //finds            int fiducialIndex = i / 2;            //                    Point3d presentLocation = expectedSystem            //                            .getFiducialLocation(fiducialIndex);            ///System.out.println(presentLocation);            //double ft1 = fidGuess.x - presentLocation.x;            //double ft2 = fidGuess.y - presentLocation.y;            ///double ft3 = fidGuess.z - presentLocation.z;            //System.out.println(ft1);            //System.out.println(ft2);            //System.out.println(ft3);            //                    expectedSystem.setFiducialTranslation(            //                            t1,t2,t3,fiducialIndex);            try            {                xGuess[sampleInputOffset + 3 * fiducialIndex] = fidGuess.x;                xGuess[sampleInputOffset + 3 * fiducialIndex + 1] = fidGuess.y;                xGuess[sampleInputOffset + 3 * fiducialIndex + 2] = fidGuess.z;            }            catch (Exception e)            {                System.out.println("offset is");                System.out.println(sampleInputOffset);                System.out.println("fiducial index is");                System.out.println(fiducialIndex);                System.out.println(e);                throw new RuntimeException("generating a guess failed");            }            //expectedSystem.reCenter();        }        //OutputGenerator.printArray(xGuess);        return xGuess;    } //    public double[] getSystemParams()//    {//        double[] output = new double[getNumSystemParams()];//        output[0] = expectedSystem.getDetectorLocation(0).x;//        //        Vector3d horz0 = expectedSystem.getSDP(0).getDetector().getOrientation().getB1();//        output[1] = horz0.x;//        output[2] = horz0.y;//        output[3] = horz0.z;//        Vector3d vert0 = expectedSystem.getSDP(0).getDetector().getOrientation().getB2();//        output[4] = vert0.x;//        output[5] = vert0.y;//        output[6] = vert0.z;//        //        Point3d srcCenter1 = expectedSystem.getSourceLocation(1);//        output[7] = srcCenter1.x;//        output[8] = srcCenter1.y;//        output[9] = srcCenter1.z;//        //        Point3d detCenter1 = expectedSystem.getDetectorLocation(1);//        output[10] = detCenter1.x;//        output[11] = detCenter1.y;//        output[12] = detCenter1.z;//        Vector3d horz1 = expectedSystem.getSDP(1).getDetector().getOrientation().getB1();//        output[13] = horz1.x;//        output[14] = horz1.y;//        output[15] = horz1.z;//        Vector3d vert1 = expectedSystem.getSDP(1).getDetector().getOrientation().getB2();//        output[16] = vert1.x;//        output[17] = vert1.y;//        output[18] = vert1.z;//        //        for (int i = 0; i<expectedSystem.getNumberOfFiducials(); i++)//        {//            Point3d fidLocation = expectedSystem.getFiducialLocation(i);//            output[19 + 3*i] = fidLocation.x;//            output[19 + 3*i + 1] = fidLocation.y;//            output[19 + 3*i + 2] = fidLocation.z;//        }//        return output;//    }	    public int getRequiredOutputSize()    {        return expectedSystem.availableData(1) * (1 + rotations);    }    public double[] getSampleInput()    {        double[] xGuess = new double[getRequiredInputSize()];        return xGuess;    }    public boolean outputInBounds(double[] data)    {        return super.outputInBounds(data)                && data.length == getRequiredOutputSize();    }    /**     * @effects: set the maximum assumed amount of imaging error in actualvalues     * Used in the punishment function.     * @param d     *///    public void setMaxPixelError(double pixelError)//    {//        //this.maxPixelError = pixelError;//    }    public static void main1()    {        XRAYSystem exp = XRAYSystem.BuildDefault();        exp.addDefaultSourceDetectorPair(70000, 140000);        exp.addDefaultSourceDetectorPair(70000, 140000);        exp.rotateSDP(90, 1);//        exp.reCenter();        double[] expectedRotations = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100,                110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220,                230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350 };        //double[] expectedRotations = {};        int fids = 100;        for (int i = 0; i < fids; i++)        {            exp.addDefaultLightFiducial(0, 0, 0);        }        double[] actualValues = new double[exp                .availableData(expectedRotations.length + 1)];        for (int i = 0; i < actualValues.length; i++)        {            actualValues[i] = 1;        }        CalibMovingStatUnknown og = new CalibMovingStatUnknown(exp,                expectedRotations, actualValues);        double[] input = og.getSampleInput();        int iterations = 10000;        for (int i = 0; i < iterations; i++)        {            og.calcF(input);            for (int k = 0; k < input.length; k++)            {                input[k] = input[k] + .01;            }        }    }    public static void main2()    {        XRAYSystem exp = XRAYSystem.BuildDefault();        exp.addDefaultSourceDetectorPair(70000, 70000);        exp.addDefaultSourceDetectorPair(70000, 70000);        exp.rotateSDP(90, 1);//        exp.reCenter();        double[] expectedRotations = { 90, 180 };        int fids = 2;        for (int i = 0; i < fids; i++)        {            exp.addDefaultLightFiducial(0, 0, 0);        }        double[] actualValues = new double[exp                .availableData(expectedRotations.length + 1)];        for (int i = 0; i < actualValues.length; i++)        {            actualValues[i] = 1;        }        CalibMovingStatUnknown og = new CalibMovingStatUnknown(exp,                expectedRotations, actualValues);        double[] input = og.getSampleInput();        //input[0] = 5000;        //input[1] = 6000;        //input[2] = 7000;        //input[3] = 8000;        //input[4] = 9000;        //input[5] = 10000;        input[6] = 5;        input[7] = 10;        input[8] = 15;        input[9] = 5;        input[10] = 10;        input[11] = 15;        input[12] = 3;        input[13] = 6;        input[14] = 9;        input[15] = 100;        input[16] = 105;        input[17] = 110;        input[18] = 1000;        input[19] = 5000;        input[20] = 7000;        double[] output = og.calcF(input);    }    public double[][] showOutput(double[] X, int sdp, int rotation, int radius)    {        this.calcF(X);        DetectorArray det = expectedSystem.getSDP(sdp).getDetector();        double[][] output = new double[det.getRows()][det.getColumns()];        double[] relevantPortion = new double[expectedSystem                .getNumberOfFiducials() * 2];        int offset = (rotation + 1) * expectedSystem.availableData(1) + sdp * 2                * expectedSystem.getNumberOfFiducials();        for (int i = 0; i < relevantPortion.length; i++)        {            relevantPortion[i] = expectedOutput[offset + i];        }        for (int i = 0; i < relevantPortion.length; i = i + 2)        {            for (int j = -1 * radius; j < radius + 1; j++)            {                for (int k = -1 * radius; k < radius + 1; k++)                {                    int column = (int) Math.floor(relevantPortion[i]) + j;                    int row = (int) Math.floor(relevantPortion[i + 1]) + k;                    if ((row < det.getRows()) && (row > -1)                            && (column < det.getColumns()) && (column > -1))                    {                        output[row][column] = 1;                    }                }            }        }        return output;    }    public static void main(String[] args)    {        main4();    }    public static void main3()    {        System.out.println("new");        BufferedWriter out;        NumberFormat nf = NumberFormat.getInstance();        String filename = "NewCalibresults";        File f = new File(filename);        try        {            out = new BufferedWriter(new FileWriter(f));        }        catch (Exception e)        {            throw new RuntimeException("File creation problem: " + filename);        }        XRAYSystem exp = XRAYSystem.BuildDefault();        exp.addDefaultSourceDetectorPair(70000, 140000);        exp.addDefaultSourceDetectorPair(70000, 140000);        exp.rotateSDP(90, 1);//        exp.reCenter();        double[] expectedRotations = { 90, 180 };        //double[] expectedRotations = {};        int fids = 5;        for (int i = 0; i < fids; i++)        {            exp.addDefaultLightFiducial(0, 0, 0);        }        double[] actualValues = new double[exp                .availableData(expectedRotations.length + 1)];        for (int i = 0; i < actualValues.length; i++)        {            actualValues[i] = 1;        }        CalibMovingStatUnknown og = new CalibMovingStatUnknown(exp,                expectedRotations, actualValues);        double[] input = og.getSampleInput();        int iterations = 4;        for (int i = 0; i < iterations; i++)        {            double[] output = og.calcF(input);            try            {                for (int j = 0; j < output.length; j++)                {                    out.write(nf.format(output[j]));                    out.write("\n");                }            }            catch (Exception e)            {                System.out.println(e);                throw new RuntimeException("failure to write");            }            for (int k = 0; k < input.length; k++)            {                input[k] = input[k] + 10;            }        }        try        {            out.close();        }        catch (Exception e)        {            throw new RuntimeException("failed to close");        }    }        public static void main4()    {        XRAYSystem exp = XRAYSystem.BuildDefault();        exp.addDefaultSourceDetectorPair(70000, 70000);        exp.addDefaultSourceDetectorPair(70000, 70000);        exp.rotateSDP(90, 1);//        exp.reCenter();        double[] expectedRotations = { 90, 180 };        int fids = 2;        for (int i = 0; i < fids; i++)        {            exp.addDefaultLightFiducial(0, 0, 0);        }        double[] actualValues = new double[exp                .availableData(expectedRotations.length + 1)];        for (int i = 0; i < actualValues.length; i++)        {            actualValues[i] = 1;        }        CalibMovingStatUnknown og = new CalibMovingStatUnknown(exp,                expectedRotations, actualValues);        System.out.println(og);    }}