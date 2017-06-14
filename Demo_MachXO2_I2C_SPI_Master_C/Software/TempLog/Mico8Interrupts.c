#include "DDStructs.h"

#ifndef __MICO_NO_INTERRUPTS__
#include "MicoInterrupts.h"
#include "MicoUart.h"
#include "MicoPassthru.h"
#include "MicoPassthru.h"

void MicoISRHandler();

void __IRQ(void) __attribute__ ((interrupt));

void __IRQ(void)
{
	MicoISRHandler();
}

void MicoISRHandler()
{

  unsigned char ip, im, Mask, IntLevel;
  do {
		MICO8_READ_IM(im);
		MICO8_READ_IP(ip);

		ip &= im;
		Mask = 0x1;
		IntLevel = 0x0;

		if ( ip!=0 ) {
				do {
        			if (Mask & ip) {
						switch(IntLevel) {
							case 0:
								MicoUartISR(&uart_core_uart);
								break;
							case 1:
								MicoPassthruISR(&slave_passthru_slave_LCD);
								break;
							case 2:
								MicoPassthruISR(&slave_passthru_slave_EFB);
								break;
							default:
								break;
	    				}
	    				MICO8_PROGRAM_IP(Mask);
						break;
					}
					Mask <<= 0x1;
					++IntLevel;
				} while (1);
		} else {
            break;
		}
	} while (1);

	return;
 }
#endif