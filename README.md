# Sonic Concepts TPO Control Toolbox

## Overview

Third-party toolbox for controlling the Sonic Concepts Transducer Power Output (TPO) systems using a USB connection and MATLAB. The toolbox functions are based on MATLAB codes provided by Sonic Concepts, Inc (distributed under an MIT license), extended to give a uniform interface, add documentation and error checking, and to specify all input parameters in base SI units (Hz, s, etc).

The codes were written primarily for transcranial ultrasound stimulation (TUS) experiments using a 2-channel TPO (TPO-201, Firmware version 4.12) and a 2-channel annular array transducer (Sonic Concepts H115-2AA). The codes have only been tested using this configuration using Windows 10. Compatability with other TPO models, firmware versions, and operating systems is unknown.

For questions or comments, contact Bradley Treeby (University College London): b.treeby@ucl.ac.uk.

## Toolbox

The toolbox folder contains a series of functions for connecting to the TPO (using serial commands over USB), setting the TPO parameters, and triggering the TPO output. See `studies\vep-modulation\setupTPOV1.m` for an example of how to connect to the TPO and set the waveform parameters.

Two functions are provided for triggering the output. Use `transmitStart` when timing is not critical, and `armTransmit` followed by `fprintf(serialTPO, '\r')` when precise timing is important. Sham functions are also provided.

## Study Codes

Codes used for published studies are contained in the `studies` folder.

* **auditory-artefact**: Codes used for Johnstone, A., Nandi, T., Martin, E., Bestmann, S., Stagg, C. and Treeby, B., 2021. A range of pulses commonly used for human transcranial ultrasound stimulation are clearly audible. Brain Stimulation: Basic, Translational, and Clinical Research in Neuromodulation, 14(5), pp.1353-1355. https://doi.org/10.1016/j.brs.2021.08.015
* **vep-modulation**:
