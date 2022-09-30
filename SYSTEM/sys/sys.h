#ifndef __SYS_H__
#define __SYS_H__

#ifdef __cplusplus
 extern "C" {
#endif 

#include <stdio.h>
#include "stm32h7xx.h"
#include "stm32h7xx_hal.h"

#define SYSTEM_SUPPORT_OS   0

#define BITBAND(addr, bitnum) ((addr & 0xF0000000)+0x2000000+((addr &0xFFFFF)<<5)+(bitnum<<2)) 
#define MEM_ADDR(addr)  *((volatile unsigned long  *)(addr)) 
#define BIT_ADDR(addr, bitnum)   MEM_ADDR(BITBAND(addr, bitnum))

#define GPIOA_ODR_Addr    (GPIOA_BASE+20) //0x40020014
#define GPIOB_ODR_Addr    (GPIOB_BASE+20) //0x40020414 
#define GPIOC_ODR_Addr    (GPIOC_BASE+20) //0x40020814 
#define GPIOD_ODR_Addr    (GPIOD_BASE+20) //0x40020C14     

#define GPIOA_IDR_Addr    (GPIOA_BASE+16) //0x40020010 
#define GPIOB_IDR_Addr    (GPIOB_BASE+16) //0x40020410 
#define GPIOC_IDR_Addr    (GPIOC_BASE+16) //0x40020810 
#define GPIOD_IDR_Addr    (GPIOD_BASE+16) //0x40020C10 

#define PAout(n)   BIT_ADDR(GPIOA_ODR_Addr,n)  
#define PAin(n)    BIT_ADDR(GPIOA_IDR_Addr,n) 

#define PBout(n)   BIT_ADDR(GPIOB_ODR_Addr,n)
#define PBin(n)    BIT_ADDR(GPIOB_IDR_Addr,n) 

#define PCout(n)   BIT_ADDR(GPIOC_ODR_Addr,n)
#define PCin(n)    BIT_ADDR(GPIOC_IDR_Addr,n) 

#define PDout(n)   BIT_ADDR(GPIOD_ODR_Addr,n)
#define PDin(n)    BIT_ADDR(GPIOD_IDR_Addr,n) 

#define DTCM_MEM   __attribute__((section(".dtcmram")))
#define DTCM_MEM_ALIGN(x)   __attribute__((section(".dtcmram"))) __attribute__((aligned(x)))

#define D2_MEM   __attribute__((section(".ramd2")))
#define D2_MEM_ALIGN(x)   __attribute__((section(".ramd2"))) __attribute__((aligned(x)))

#define D3_MEM   __attribute__((section(".ramd3")))
#define D3_MEM_ALIGN(x)   __attribute__((section(".ramd3"))) __attribute__((aligned(x)))

HAL_StatusTypeDef Stm32_Clock_Init(uint32_t pllm, uint32_t plln, uint32_t pllp, uint32_t pllq);

#ifdef __cplusplus
}
#endif
#endif
