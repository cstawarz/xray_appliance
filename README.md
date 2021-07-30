# xray_appliance

This is the software for running the DiCarlo Lab's X-ray appliance.

To build and run the software, first install [NI-DAQmx Base](https://www.ni.com/en-us/support/downloads/drivers/download.ni-daqmx-base.html#326058) and [MATLAB](https://www.mathworks.com/products/matlab.html) R2021a.  Then, open `XRIPT.xcworkspace` in Xcode, select the "XRIPT" target, and build.

*Note:* Due to its dependency on NI-DAQmx Base, this software will run only on macOS 10.14.  However, you should be able to build it on newer macOS versions.
