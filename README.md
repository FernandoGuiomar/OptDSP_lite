## General Description of the OptDSP Library ##

The OptDSP library includes a set of m-files to implement **transmitter- and receiver-side digital signal processing (DSP) for coherent optical communication systems**.  
Currently supported functionalities: 

+ pulse shaping (RRC, SRRC, Gaussian, ...);  
+ QAM modulation (BPSK, QPSK, 8QAM, 16QAM, 32QAM, 64QAM, 128QAM, 256QAM, 512QAM);  
+ Probabilistic Shaping;  
+ Emulation of laser phase and intensity noise;
+ matched filtering (SRRC);  
+ carrier phase estimation and removal (Viterbi&Viterbi, blind-phase search, maximum likelihood, decision-directed, data-aided, ...);  
+ signal demodulation and decision (BER, SER, EVM, MSE, MI, ...);


In addition, the library also includes a set of functions to perform general purpose DSP operations such as:  

+ low-pass/band-pass filtering (frequency-domain);  
+ digital resampling;  
+ synchronization of Tx and Rx signals;  
+ conversion between performance metrics (BER, SNR, MI, ...);


## How to Use the OptDSP Library ##
The OptDSP library requires the use of MATLAB and it includes an *_examples* folder containing simple application examples that can be run by anyone. Users are encouraged to adapt the provided examples to their own application. Note: when developing your own project, please consider placing your main-files outside of the OptDSP directory, so that they are out of the Git version control. To load the OptDSP library, simply place the following line of code in the preamble of you m-file:  
addpath(genpath('path\to\OptDSP\library'));


## Acknowledgment ##

This library and its included routines were developed by Fernando Guiomar and supported by the European Commission (EC) within the framework of a Marie Skłodowska-Curie Individual Fellowship, project Flex-ON: Flexible Optical Networks – Time Domain Hybrid QAM: DSP and Physical Layer Modelling, with grant agreement number 653412.  
[http://cordis.europa.eu/project/rcn/194861_en.html](http://cordis.europa.eu/project/rcn/194861_en.html)


