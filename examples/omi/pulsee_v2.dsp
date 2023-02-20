declare name " Pulsee ";
declare author " Scott E. Petersen " ;
declare copyright " (c) SEP 2023 ";
declare version " 0.02a ";
declare license " BSD ";

// Import the standard library so we can use preexisting objects
import("stdfaust.lib");

/* -- OSCILLATOR SECTION -- comment/uncomment to choose your source. For this workshop, use os.lf_imptrain and keep lfn line uncommented */

// src = no.noise*0.1;
// src = os.pulsetrain(2 + lfn, 0.5)*0.2;
// src = os.square(1 + lfn)*0.25;
lfn = no.lfnoiseN(3, 48000/100) : abs * drift;
src = os.lf_imptrain(pfreq + lfn)*amp;

/* -- GUI SECTION -- */

// knob for overall amplitude scaler
amp = oscGroup(hslider("[1]amp[style:knob]",0.1,0.0,0.3,0.001)) : si.smoo;
// knob for impulse frequency
pfreq = oscGroup(hslider("[2]freq[style:knob]",1.0,0.0,30.0,0.1)) : si.smoo;
// knob for random number amount
drift = oscGroup(hslider("[3]drift[style:knob]",0.0,0.0,10.0,0.1)) : si.smoo;

// button for filter order
order = filtGroup(hslider("[1]order[style:menu{'2nd':0;'4th':1}]",0,0,1,1));
// knob for filter cutoff
cutoff = filtGroup(hslider("cut[style:knob]",500,10,2800,10)) : si.smoo;
// knob for delay
delay = combGroup(hslider("delay[style:knob]",mdel/2, 0, mdel, 0.1)) : si.smoo;
// knob for feedback
fdbk = combGroup(hslider("fdbk[style:knob]",0.2,0.0,1.0,0.01)) : si.smoo;
// knob for feedback
mix = verbGroup(hslider("wet amnt[style:knob]",0.01,0.0,0.1,0.001)) : si.smoo;

// Groups for GUI elements listed above
oscGroup(x) = pulseeGUI(hgroup("[A]Oscillator",x));
filtGroup(y) = pulseeGUI(hgroup("[B]Filter",y));
combGroup(z) = pulseeGUI(hgroup("[C]Comb", z));
verbGroup(v) = pulseeGUI(hgroup("[D]Reverb", v));
pulseeGUI(a) = hgroup("PULSEE", a);

/* -- FILTER SECTION -- */

// low pass
filter2 = src : fi.lowpass(2, cutoff);
filter4 = src : fi.lowpass(4, cutoff);

//comb
mdel = 8092;
comb = fi.fb_comb(mdel, delay, delay, fdbk);

// panning
pan = sp.panner(0.5);

// reverb
verb = re.stereo_freeverb(0.91521,0.9459,0.495, 7);

// signal with no reverb, panned
dry = select2(order, filter2, filter4) : comb : pan : _*(1-mix), _*(1-mix); // inverse of mix for wet/dry

// dry signal processed through reverb
wet = dry : _*mix, _*mix : verb ;

/* -- OUTPUT -- */

process = wet,dry :> _,_; // here we do not "sum" like wet + dry, but parallel process the two, resulting in 4 chans out which have to be reduced to two using the merge operator. 
 
