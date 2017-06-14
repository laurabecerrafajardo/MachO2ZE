PICO demo designers:

 

The current PICO board Environmental Scanning Demo contains an LCD driver for the 4-digit onboard display.  I extracted the main routine from the Chris’s top level code and made it a proper module.  Please use in your designs as appropriate.

 

Note: the module expects 2.08Mhz input clock.   If a different frequency is desired, you must adjust LCDFrameclk and LCDPWMclk to suit.

 

Regards,

Steve Hosner

