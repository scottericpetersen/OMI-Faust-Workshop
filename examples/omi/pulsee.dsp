declare name " Pulsee ";
declare author " Scott E. Petersen " ;
declare copyright " (c) SEP 2023 ";
declare version " 0.02 ";
declare license " BSD ";


/* -- 1. LIBRARIES ------------------------------------------------------------------- */

// -- Import the standard library so we can use preexisting objects
import("stdfaust.lib");


/* -- 2. CONSTANTS AND QUANTITIES ---------------------------------------------------- */

d_max = 0.1; // maximum value for wet/dry mix knob
mdel = 8092; // maximym delay amount in samples for the comb filter


/* -- 3. GUI SECTION ----------------------------------------------------------------- */

// -- overall amplitude scaler
amp = oscGroup(hslider("[1]amp[style:knob]",0.2,0.0,1.0,0.01)) : si.smoo; // overall amplitude
// -- impulse frequency
pfreq = oscGroup(hslider("[2]freq[style:knob]",1.0,0.0,30.0,0.1)) : si.smoo; // pulse train frequency in number of pulses per second
// -- random number amount
drift = oscGroup(hslider("[3]drift[style:knob]",0.0,0.0,10.0,0.1)) : si.smoo; // random amount to add to pulse train frequency if desired
// -- filter order
order = filtGroup(hslider("[1]order[style:menu{'2nd':0;'4th':1}]",0,0,1,1)); // selector menu for filter order, selects from two output options
// -- filter cutoff
cutoff = filtGroup(hslider("cut[style:knob]",500,10,2800,10)) : si.smoo; // lowpass filter cutoff frequency. 
// -- delay amount (miliseconds)
delay = combGroup(hslider("delay[style:knob]",mdel/2, 0, mdel, 1)) : si.smoo; // delay time control for comb filter
// -- feedback
fdbk = combGroup(hslider("fdbk[style:knob]",0.2,0.0,1.0,0.01)) : si.smoo; // feedback control for comb filter
// -- reverb wet/dry mix
mix = verbGroup(hslider("wet amnt[style:knob]",0.01,0.0,d_max,0.001)) : si.smoo;

// -- groups for GUI elements listed above
oscGroup(x) = pulseeGUI(hgroup("[A]Oscillator",x));
filtGroup(y) = pulseeGUI(hgroup("[B]Filter",y));
combGroup(z) = pulseeGUI(hgroup("[C]Comb", z));
verbGroup(v) = pulseeGUI(hgroup("[D]Reverb", v));
pulseeGUI(a) = hgroup("PULSEE", a);


/* -- 4. OSCILLATOR SECTION ----------------------------------------------------------- */

lfn = (no.lfnoiseN(3, 48000/100) + 1.001) * drift; // random low frequency noise to add to pulse train frequency parameter if desired.
src = os.lf_imptrain(pfreq + lfn)*amp; // pulse train oscillator - the sound generator in this program


/* -- 5. FILTER SECTION --------------------------------------------------------------- */

// -- low passes
filter2 = src : fi.lowpass(2, cutoff); // The order number (2) is a compile time argument and cannot be changed post-compile.
filter4 = src : fi.lowpass(4, cutoff); // So here we create two filters of different orders and use select2 at the output to change which we hear.
// -- comb filter
comb = fi.fb_comb(mdel, delay, delay, fdbk); // comb filter 


/* -- 6. EFFECTS SECTION -------------------------------------------------------------- */

// panning
pan = sp.panner(0.5); // pan mono signal to center
// reverb
verb = re.stereo_freeverb(0.91521,0.9459,0.495, 7); // freeverb reverberator


/* -- 7. MIXING ------------------------------------------------------------------------ */

// -- signal with no reverb, panned
dry = select2(order, filter2, filter4) : comb : pan : _*(d_max-mix), _*(d_max-mix); // inverse of mix for wet/dry
// -- dry signal processed through reverb
wet = dry : _*mix, _*mix : verb ;


/* -- 8. OUTPUT ------------------------------------------------------------------------ */

process = wet,dry :> _,_; // here we do not "sum" like wet + dry, but parallel process the two, resulting in 4 chans out which have to be reduced to two using the merge operator. 
 
