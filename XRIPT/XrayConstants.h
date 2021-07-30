/*
 *  XrayConstants.h
 *  XRIPT
 *
 *  Created by bkennedy on 3/18/08.
 *  Copyright 2008 MIT. All rights reserved.
 *
 */

typedef enum tagDetector {DETECTOR_1, 
						  DETECTOR_2, 
						  UNDEFINED_DETECTOR} Detector;

#define XRAY_OBJECT_COLOR @"C"
#define XRAY_OBJECT_PATH @"P"

 // Volts
#define MAX_XRAY_VOLTAGE 50000.0
#define MIN_XRAY_VOLTAGE 0.0
// Amps
#define MAX_XRAY_CURRENT 0.001
#define MIN_XRAY_CURRENT 0.0

#define XRAY_DEVICES_ATTACHED 1

