#include "stm32h7xx_hal.h"
#include "sys.h"
#include "mpu.h"
#include <stdio.h>
#include <stdlib.h>
#include "delay.h"
#include "usart.h"
#include "led.h"

void Delay(__IO uint32_t nCount);
void Delay(__IO uint32_t nCount)
{
    while(nCount--){}
}
uint8_t mpudata __attribute__((section(".dtcmram"))) = 100;

int main(void)
{
    MPU_SetProtection();
    SCB_EnableICache();		// 使能ICache
	SCB_EnableDCache();		// 使能DCache
    SCB->CACR = 1 << 2;     // 强制开启D cache 透写，确保Cache和ram中数据一致性
    HAL_Init(); //初始化 HAL 库
    Stm32_Clock_Init(5,192,2,2); //设置时钟,480Mhz
    /* System Clock Update */
    SystemCoreClockUpdate();
    
    delay_init(HAL_RCC_GetSysClockFreq()/1000000);//1US跑的tick数
    
    uart_init(115200);
    led_init();
    printf("welcome to use stm32h7xxxx\r\n");
    printf("sys clock is %lu\r\n",HAL_RCC_GetSysClockFreq());
    printf("HCLK clock is %lu\r\n",HAL_RCC_GetHCLKFreq());
    printf("mpudata address = %p\r\n",&mpudata);
    printf("mpudata befor = %d\r\n",mpudata);
    while(1)
    {
        printf("welcome to use stm32h7xxxx\r\n");
       HAL_Delay(1000);
       led_on();
       HAL_Delay(1000);
       led_off();
       mpudata = 110;
       printf("mpudata[0] = %d\r\n",mpudata);
    }
    return 0;
}