## General Description of the OptDSP Library ##

The OptDSP library includes a set of m-files to implement **transmitter- and receiver-side digital signal processing (DSP) for coherent optical communication systems**.  
Currently supported functionalities: 

+ pulse shaping (RRC, SRRC, Gaussian, ...);  
+ QAM modulation (BPSK, QPSK, 8QAM, 16QAM, 32QAM, 64QAM, 128QAM, 256QAM, 512QAM);  
+ Probabilistic Shaping;  
+ Electronic subcarrier multiplexing;  
+ Emulation of DAC and ADC impairments (bit precision, bandwidth, clipping, timing skew, ...);
+ Emulation of laser phase and intensity noise;
+ matched filtering (SRRC);  
+ clock recovery (only for QPSK so far);  
+ optical frontend compensation (deskew, orthonormalization, DC removal, ...);  
+ adaptive linear equalization (CMA, LMS, RDE, ...);  
+ frequency offset estimation and removal;  
+ carrier phase estimation and removal (Viterbi&Viterbi, blind-phase search, maximum likelihood, decision-directed, data-aided, ...);  
+ signal demodulation and decision (BER, SER, EVM, MSE, MI, ...);


For simpler use of the implemented DSP subsystems, several DSP sets are provided, ready for use in: 

+ single-carrier and multi-subcarrier transmission;
+ optical B2B applications (simulation and experimental);  
+ fiber propagation applications (simulation and experimental);  
+ ideal simulation setups.


In addition, the library also includes a set of functions to perform general purpose DSP operations such as:  

+ low-pass/band-pass filtering (frequency-domain);  
+ FFT block processing (overlap-and-save, overlap-and-add);  
+ digital resampling;  
+ synchronization of Tx and Rx signals;  
+ digital monitoring of signal impairments (estimation of OSNR, chromatic dispersion, PMD ...);
+ conversion between performance metrics (BER, SNR, MI, ...);
+ estimation of maximum reach with linear and nonlinear impairments (requires to supply external EGN data).


## How to Use the OptDSP Library ##
The OptDSP library requires the use of MATLAB and it includes an *_examples* folder containing simple application examples that can be run by anyone. Users are encouraged to adapt the provided examples to their own application. Note: when developing your own project, please consider placing your main-files outside of the OptDSP directory, so that they are out of the Git version control. To load the OptDSP library, simply place the following line of code in the preamble of you m-file:  
addpath(genpath('path\to\OptDSP\library'));


## Acknowledgment ##

This library and its included routines were developed by Fernando Guiomar and supported by the European Commission (EC) within the framework of a Marie Skłodowska-Curie Individual Fellowship, project Flex-ON: Flexible Optical Networks – Time Domain Hybrid QAM: DSP and Physical Layer Modelling, with grant agreement number 653412.  
[http://cordis.europa.eu/project/rcn/194861_en.html](http://cordis.europa.eu/project/rcn/194861_en.html)


