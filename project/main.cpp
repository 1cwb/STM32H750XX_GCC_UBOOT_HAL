#include "stm32h7xx_hal.h"
#include "sys.h"
#include "mpu.h"
#include <stdio.h>
#include <stdlib.h>
#include "delay.h"
#include "usart.h"
#include "led.h"
#include "w25qxx.h"
#include "sdram.h"

typedef  void (*pFunction)(void);
pFunction JumpToApplication;

int main(void)
{
    MPU_SetProtection();
    SCB_EnableICache();		// 使能ICache
	SCB_EnableDCache();		// 使能DCache
    HAL_Init(); //初始化 HAL 库
    Stm32_Clock_Init(5,192,2,2); //设置时钟,480Mhz
    /* System Clock Update */
    SystemCoreClockUpdate();
    delay_init(HAL_RCC_GetSysClockFreq()/1000000);//1US跑的tick数
    uart_init(115200);
    led_init();
    printf("Uboot runing...\r\n");
    printf("sys clock is %lu\r\n",HAL_RCC_GetSysClockFreq());
    printf("HCLK clock is %lu\r\n",HAL_RCC_GetHCLKFreq());
    if(QSPI_W25Qxx_Init() != QSPI_W25Qxx_OK)
    {
        printf("ERROR QSPI_W25Qxx_Init Fail!! \r\n");
    }
	else
	{
		printf("QSPI_W25Qxx_Init OK\r\n");
	}
    if(QSPI_W25Qxx_MemoryMappedMode() != QSPI_W25Qxx_OK) 	 // 配置QSPI为内存映射模式
    {
        printf("ERROR Enter QSPI_W25Qxx_MemoryMappedMode Fail\r\n");
    }
	else
	{
		printf("Enter QSPI_W25Qxx_MemoryMappedMode OK\r\n");
	}
    if(MX_FMC_Init() != HAL_OK)
	{
		printf("ERROR MX_FMC_Init\r\n");
	}
	else
	{
		printf("MX_FMC_Init OK\r\n");
	}
	if(SDRAM_Check() != HAL_OK)
	{
		printf("ERROR Check SDRAM Fail\r\n");
	}
	else
	{
		printf("Check SDRAM OK\r\n");
	}
    //SysTick->CTRL = 0;		// 关闭SysTick
	//SysTick->LOAD = 0;		// 清零重载值
	//SysTick->VAL = 0;			// 清零计数值
    SCB_DisableICache();		// 关闭ICache
	SCB_DisableDCache();		// 关闭Dcache

    //printf("tony run xxxx now ADDR = %x\r\n",(*(__IO unsigned int*) (W25Qxx_Mem_Addr + 4)));
    JumpToApplication = (pFunction) (*(__IO uint32_t*) (W25Qxx_Mem_Addr + 4));	// 设置起始地址
	//__set_MSP(*(__IO uint32_t*) W25Qxx_Mem_Addr);	// 设置主堆栈指针
	//printf("跳转到W25Q64运行用户程序>>>\r\n\r\n");

	JumpToApplication();			// 执行跳转


    while(1)
    {
       HAL_Delay(1000);
       led_on();
       HAL_Delay(1000);
       led_off();
    }
    return 0;
}
