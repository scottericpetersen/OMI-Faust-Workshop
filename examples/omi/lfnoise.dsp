import("stdfaust.lib");
import("music.lib");

rate = SR/100.0; // new random value every 100 samples (SR from music.lib);
process = no.lfnoise0(rate),   // sampled/held noise (piecewise constant)
          no.lfnoiseN(3,rate), // lfnoise0 smoothed by 3rd order Butterworth LPF
          no.lfnoise(rate);    // lfnoise0 smoothed with no overshoot

