# Faust for Users of SuperCollider

This document attempts to capture some of the obvious pitfalls and differences when working with Faust coming from a SuperCollider background. 


## Inputs and Outputs

In SuperCollider, inputs and outputs to any program or sound-making function must specify that input or output with a Bus, In or Out (or equivalent) object. This requires explicit specification of the input or output channel unless processing from or to hardware is desired. (Lowest channel numbers are hardware reserved.) 

In Faust, inputs and outputs *may* explicitly be created. However, it is not uncommon to see code where there are no inputs or outputs specified:

```
import("stdfaust.lib");
process = fi.lowpass(2,1200);
```
In this example, the input and output to the filter are implicit and related to the number of channels of the fi.lowpass class itself. In this case, one input and one output from the program will be provided because the class is mono.

To explicity state inputs and outputs, you may use the underscore syntax:

```
process _,_ : StereoObject : _,_;
```

Here, it is understood that the Stereo Object is, in fact, two-channel in and two-channel out. If it is not, this code will throw an error at compile time. 

For conversion from input and output channel numbers, please see the Compositional Operators section in the Faust manual, specifically the split ```<:``` and merge ```:>``` operators. 

## Standard Signal Operations

In SuperCollider, summing, multiplying, or otherwise combining signals involves the use of binary operators like +, *, etc. To sum two multichannel signals one uses the add operator. 

```
SinOsc.ar(400, 0, [1,1]) + SinOsc.ar(500, 0, [1,1]);

```

This results in a two-channel output where each channel (0 and 1) from each Ugen are summed. 

In Faust, this is not valid syntax, and operations performed on multichannel signals may seem unintuitive. For example, scaling a two-channel signal in SuperCollider is done this way:

```
SinOsc.ar(mul:[1,1]) * 0.5;
```
Both channels of the SinOsc are multiplied by 0.5, resulting in a SinOsc with two channels of 0.5 amplitude output. 

In Faust, any of the above operations results in output equal to the number of signals, so a two channel signal + another two-channel signal results in a four-channel signal output. Similarly, the scaling operation above results in a three-channel output, rather than a scaled two-channel output.

Because of the way Faust treats signals and operations, the operation, whatever it is must be applied to the number of channels explicitly. 

```
signal : _*mix, _*mix
```

Summing two multichannel signals is handled entirely differently according to the compositional operators. To sum two multichannel signals we do not use the + binary operator, rather we place the signals in parallel and then merge the two.

```
signal1,signal2 :> _,_;
```

The merge ```:>``` is required because parallel processing the two two-channel signals results in a four-channel output. 
