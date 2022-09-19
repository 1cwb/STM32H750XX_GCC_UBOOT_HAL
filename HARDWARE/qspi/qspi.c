#include "qspi.h"
#include "stm32h7xx.h"
#include "stm32h7xx_hal.h"

QSPI_HandleTypeDef QSPI_Handler;

HAL_StatusTypeDef QSPI_Init()
{
    QSPI_Handler.Instance=QUADSPI; //QSPI
    QSPI_Handler.Init.ClockPrescaler=2; //QPSI 分频比， W25Q256 最大频率为 104M，//所以此处应该为 2， QSPI 频率就为 240/(2+1)=80MHZ
    QSPI_Handler.Init.FifoThreshold=4; //FIFO 阈值为 4 个字节
    QSPI_Handler.Init.SampleShifting=QSPI_SAMPLE_SHIFTING_HALFCYCLE;
    QSPI_Handler.Init.FlashSize=POSITION_VAL(0X800000)-1; //SPI FLASH 大小，
    QSPI_Handler.Init.ChipSelectHighTime=QSPI_CS_HIGH_TIME_5_CYCLE;
    QSPI_Handler.Init.ClockMode=QSPI_CLOCK_MODE_0; //模式 0
    QSPI_Handler.Init.FlashID=QSPI_FLASH_ID_1; //第一片 flash
    QSPI_Handler.Init.DualFlash=QSPI_DUALFLASH_DISABLE; //禁止双闪存模式
    if(HAL_QSPI_Init(&QSPI_Handler)==HAL_OK) return HAL_OK; //QSPI 初始化成功
    else return HAL_ERROR;
}

//QSPI 底层驱动,引脚配置，时钟使能
//此函数会被 HAL_QSPI_Init()调用
//hqspi:QSPI 句柄
void HAL_QSPI_MspInit(QSPI_HandleTypeDef *hqspi)
{
    GPIO_InitTypeDef GPIO_Initure;
    __HAL_RCC_QSPI_CLK_ENABLE(); //使能 QSPI 时钟
    __HAL_RCC_GPIOG_CLK_ENABLE(); //使能 GPIOB 时钟
    __HAL_RCC_GPIOF_CLK_ENABLE(); //使能 GPIOF 时钟
    //初始化 PB6 片选信号
    GPIO_Initure.Pin=GPIO_PIN_6;
    GPIO_Initure.Mode=GPIO_MODE_AF_PP; //复用
    GPIO_Initure.Pull=GPIO_PULLUP;
    GPIO_Initure.Speed=GPIO_SPEED_FREQ_VERY_HIGH; //高速
    GPIO_Initure.Alternate=GPIO_AF10_QUADSPI; //复用为 QSPI
    HAL_GPIO_Init(GPIOG,&GPIO_Initure);
    
}

uint8_t QSPI_Wait_Flag(uint32_t flag, uint8_t sta, uint32_t wtime)
{
    uint8_t flagsta = 0;
    while(wtime)
    {
        flagsta = (QUADSPI->SR&flag)?1:0;
        if(flagsta == sta)break;
        wtime --;
    }
    if(wtime)
    return 0;
    else return 1;
}

