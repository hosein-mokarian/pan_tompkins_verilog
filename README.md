


# **Pan-Tompkins Algorithm Implementation in Verilog**
### Introduction
One of the most important features of ECG signals is QRS. It is a vital sign to determine how heart is working. Although it's the largest peak in a ECG signal segment, it is really hard to detect it. The reasons are noise and physiological variability of the QRS complexes. Muscle noise, artifacts due to electrode motion, power-line interference, baseline wander, and T waves with high-frequency characteristics similar to QRS complexes are some examples of noise sources.
### Algorithm overview
Pan-Tompkins algorithm uses linear and non-linear techniques to reject noise and detect QRS complexes. A band pass filter, which contains a low pass and high pass filter, is used to remove noises. The filtered signal is passed through a derivative filter to get the slope of the signal. It might have negative values. So, a signal amplitude squaring is used to make a positive signal. It is a non-linear stage. Finally, moving window integrator (MWI) is used to make a pulse which its width equals to QRS segment. The output signals of band-pass filter and MWI in combination with adaptive thresholding are used to detect valid QRS complexes.
### Band-pass filter
The band-pass filter is composed of cascaded low-pass and high-pass filter. They are digital filters and uses integer coefficients. 

	Low-pass Filter:
		y(nT) = 2y(nT - T) - y(nT - 2 T) + x(nT) - 2x(nT- 6T) + x(nT- 12T)
	High-Pass Filter:
		y(nT) = 32x(nT - 16 T) - [y(nT - T) + x(nT) - x(nT - 32 T)]

### Derivative
In this implementation a simpler derivation is used which is just a difference of last two samples.

	y(nT) = x(nT) -  x(nT - T)

### Squaring Function

	y(nT)= x(nT) * x(nT)

### Moving-Window Integration

	y(nT) = (1/N) [x(nT- (N - 1) T) +x(nT- (N - 2) T) + - * * + x(nT)]

	  where N is the number of samples in the width of the integration window.

It is important to select an appropriate value for N. The width of the window should be approximately the same as the widest possible QRS complex. If the window is too wide, the integration waveform will merge the -QRS and T complexes together. If it is too narrow, some QRS complexes will produce several peaks in the integration waveform. The best selection is 30 and it is selected based on sample rate of ECG signals.
### Thresholding
Two threshold sets are used: one for filtered ECG signals and the other one for output of MWI. It helps to make a reliable detection. The band-pass filter increases the signal to noise ratio and it reduces the noise sensitivity of the algorithm. Also two level thresholding is used for each set. It is because of detection of missed beats. In each set, one level is half of the other one. The threshold values are adaptively set based on the valid detected QRS or noises.

	Threshold values of MWI signal:
		SPKI = 0.125 PEAKI + 0.875 SPKI 
		NPKI = 0.125 PEAKI + 0.875 NPKI
		THRESHOLD Il = NPKI + 0.25 (SPKI - NPKI)
		THRESHOLD I2 = 0.5 THRESHOLD Il
			where	PEAKI is the signal peak,
					SPKI is the running estimate of the signal peak,
					NPKI is the running estimate of the noise peak.
	
	Threshold values of Filtered ECG signal:
		SPKF = 0.125 PEAKF + 0.875 SPKF
		NPKF = 0.125 PEAKF + 0.875 NPKF
		THRESHOLD F1 = NPKF + 0.25 (SPKF - NPKF)
		THRESHOLD F2 = 0.5 THRESHOLD Fl
			where	PEAKF is the signal peak,
					SPKF is the running estimate of the signal peak,
					NPKF is the running estimate of the noise peak.

When the QRS complex is found using the second threshold:
	
	SPKI = 0.25 PEAKI + 0.75 SPKI
	SPKF = 0.25 PEAKF + 0.75 SPKF
	
If no peak is detected for a certain interval, the last peak which is between the two threshold value is considered as a QRS.
In some cases, beats are abnormal. To detect that, two separate measurements of the average RR interval are used. One RR-interval average is the mean of all of the most recent eight RR intervals. 

	RR AVERAGE1 = 0.125 (RRIn-I7 +RRIn-6 + -+RRn)
		where RR n is the most-recent RR interval.
A second RR -interval average is the mean of the most recent eight beats that fell within the range of 92-116 percent of the current RR-interval average. 

	RR AVERAGE2 = 0.125 (RR'_7 + RR'?6 + * * - + RR')
		where RR' is the most recent RR interval that fell between the acceptable low and high RR-interval limits.
When a irregularity is detected, the threshold values are updated as:

	THRESHOLD I1 ⇐ 0.5 THRESHOLD I1
	THRESHOLD F1 ⇐ 0.5 THRESHOLD F1

The RR-interval limits are

	RR LOW LIMIT = 92% RR AVERAGE2
	RR HIGH LIMIT = 116% RR AVERAGE2
	RR MISSED LIMIT = 166% RR AVERAGE2

If a QRS complex is not found during the interval specified by the RR MISSED LIMIT, the maximal peak reserved between the two established thresholds are considered to be a QRS candidate.
If each of the eight most-recent sequential RR intervals that are calculated from RR AVERAGE1 is between the RR LOW LIMIT and the RR HIGH LIMIT, we interpret the heart rate to be regular for these eight heart beats and

	RR AVERAGE2 ⇐ RR AVERAGE1
## Digital circuit implementation
Pan-Tompkins algorithm is a real-time and needs a very low memory space. So it is really suitable to implement in a wearable devices which monitors vital signals for a long period of time. Pan and Tompkins implemented the algorithm on a Z80 processor using assembly language. Now, I have implemented it as a whole digital circuit.
The algorithm has three phases including: *start up*, *learning phase 1*, *learning phase 2* and *detection*. The first state after reset is *start up*. In this state, it waits to find the first peak of MWI which is valid for 200ms. When it takes place, it triggers a timer and goes to learning phase 1. The *learning phase 1* takes 2 second and it finds the maximum value of PEAKI and PEAKF also calculates the mean value of them. They are used to as a reference value to initialize the THRESHOLD I and F. When the timer is overflowed, it goes to the *learning phase 2*. In this state, it finds two successive PEAKI and uses them to calculate RR Interval value. Finally it goes to the *detection* state which is main state to perform thresholding on filtered ECG signal and output of MWI stage. The whole process is shown in Fig.1.
The control unit manages the overall flow of the algorithm. The four purple boxes show states of the control unit. In the left side of the figure, there are some blocks which implement the linear and nonlinear transforming of ECG signals. The pipeline structure is used to keep the real-time features of the algorithm. Each stage uses a shift register to make an appropriate delay on input signal. The number of registers depends on the formula. Two extra shift registers are used to align the output of high-pass filter and squared with output of MWI.
The whole process is highly depended the PEAKI which is the highest value of the MWI signal for last 200ms. To implement it, a peak detector and a timer are used. The peak detector look for a local peak value. When it is found, the timer starts the counting. It is the valid PEAKI if the timer reaches to the end. In fact, the timer will be rested when a new peak value is found otherwise it generates a pulse at the end of period. The same procedure is used for PEAKF.
There is situation win which the algorithm could not find any QRS for RR_MISSED_LIMIT value. In this situation, It has to search back and use the last detected PEAKI which is not greater than THRESHOULD I. A free timer is used to count RR_INTERVAL. It rests when a PEAKI detected. If the timer value is greater than RR_MISSED_VALUE, the timer is loaded by the LAST_RR_INTERVAL. It is the time when the last peak value could not pass the thresholding level. It is stored and used now. The search-back process is shown as a solid white box in *detection* state in Fig.1.
When the peaks are less than threshold values, the NPU pulse is generated to trigger the parameter signal updater block. Otherwise, the SPU pulse is generated to update signal parameters. The QRS pulse is as same as the SPU. When it is one, a QRS complex is detected. 
### Verification, Simulation and Synthesize
Iverilog and GTKWave are used to simulate and verify the design. I have written a python script to analyze the *.vcd* file using *VCD reader lib* and plot the desired signals using *matplotlib*. Fig .2 shows the signals for the entire ECG signal and Fig .3 shows a focused view of the signals foe a limited segments of the ECG signal.
The *YOSYS* is used to synthesize the design.
## Chip Design
*OpenLane* is a free, open-source tools to design a digital chip. It uses *SKY130 PDK*. Both of them are supported by *Efabless* and *Google*. Fig .4 shows the designed chip in *KLayout* software.

