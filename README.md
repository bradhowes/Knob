# Knob

Simple UISlider-like iOS control that depicts its path as an arc using CoreAnimation layers.

![](example.png)

Like UISlider, Touch movements control the value though with some deviations. For my implementation:

* Only vertical movements change the value. Moving up will increase the value, moving down will decrease it.
* By default, touch sensitivity is set to 4x the height of the knob -- a touch moving 4x the height would
  chanage the value from 0.0 to 1.0. See the documentation for the `touchSensitivity` parameter.
* Touch sensitivity can be increased by moving the touch horizontally away from the control (either direction).
  This is similar to the change in "scrubbing" speed when watching a video -- the further the touch moves away
  from the scrubber, the finer the positioning is within the video.
* For now, this control reports value changes continuously -- there is no way to disable this as there is for
  UISlider.

The above picture was taken from my [SoundFonts](https://github.com/bradhowes/SoundFonts) iOS app where the
knobs control various audio effects settings.
