#include "DDStructs.h"

void LatticeDDInit(void)
{

    /* initialize uart instance of uart_core */
    MicoUartInit(&uart_core_uart);
    
    /* initialize slave_LCD instance of slave_passthru */
    MicoPassthruInit(&slave_passthru_slave_LCD);
    
    /* initialize slave_EFB instance of slave_passthru */
    MicoPassthruInit(&slave_passthru_slave_EFB);
    
    /* invoke application's main routine*/
    main();
}

