#include <avr/io.h>     //Do czesci makr
#include <util/delay.h> //Do opoznien
/*
!!!UWAGA
Aby biblioteka z delayami dzialala nalezy w ustawieniach kompilatora wlaczyc optymalizacje
*/
#include "motor.h"  //Sterowanie silnikami
#include "io_cfg.h" //Makrodefinicje pinow wejscia/wyjscia

//******************************************************************************************
//Deklaracje Diodek
#define LED1_PIN (1<<PD7)       //Przypisujemy makru LED1_PIN odpowiednie wyjscie
#define LED1_PORT PORTD         //Przypisujemy makru LED1_PORT odpowiedni port, od diodek jest D
#define LED1_ON LED1_PORT &= ~LED1_PIN      //Wlaczenie LEDa 1
#define LED1_OFF LED1_PORT |= LED1_PIN      //Wylaczenie LEDa 1
#define LED1_TOG LED1_PORT ^= (1<<LED1_PIN) //Zmiana stanu LEDa 1
#define LED2_PIN (1<<PD6)       //Przypisujemy makru LED2_PIN odpowiednie wyjscie
#define LED2_PORT PORTD         //Przypisujemy makru LED2_PORT odpowiedni port, od diodek jest D
#define LED2_ON LED2_PORT &= ~LED2_PIN      //Wlaczenie LEDa 2
#define LED2_OFF LED2_PORT |= LED2_PIN      //Wylaczenie LEDa 2
#define LED2_TOG LED2_PORT ^= (1<<LED2_PIN) //Zmiana stanu LEDa 2
void ioinit(void)           //Inicjalizacja wejsc/wyjsc
{
	M1_DDR |= (1<<M1_IN1)|(1<<M1_IN2)|(1<<M2_IN1)|(1<<M2_IN2); //jako wyjscia
	M1_P_DDR |= (1<<M1_P)|(1<<M2_P); //piny od PWMa jako wyjscia

	PG3_SLEEP_DDR |= (1<<PG3_SLEEP); //jako wyjscie
	PG3_SLEEP_PORT &= ~(1<<PG3_SLEEP); //uspienie silnikow
	FS_AB_DDR &= ~(1<<FS_AB);  //pinod FS jako wejscie

	STEP_CLK_DDR |= (1<<STEP_CLK); //jako wyjscie
	STEP_DIR_DDR |= (1<<STEP_DIR); //jako wyjscie
	STEP_ENABLE_DDR |= (1<<STEP_ENABLE); //jako wyjscie

	LED1_DDR |= (1<<LED1)|(1<<LED2); //jako wyjscia

	M3_DDR |= (1<<M3_FIN)|(1<<M3_RIN); //jako wyjscia
	M3_P_DDR |= (1<<M3_P);//jako wyjscie

	M4_DDR |= (1<<M4_FIN)|(1<<M4_RIN);//jako wyjscia
	M4_P_DDR |= (1<<M4_P); //jako wyjscie

	M5_DDR |= (1<<M5_FIN)|(1<<M5_RIN); //jako wyjscia
	M56_P_DDR |= (1<<M56_P); //jako wyjscie
	M6_DDR |= (1<<M6_FIN)|(1<<M6_RIN); //jako wyjscie

	KEY_DDR |= (1<<KEY1)|(1<<KEY2); //klucze tranzystorowe jako wyjscia
	DDRF = 0x00; //caly port jako wejscie (konieczne gdy uzywamy ADC)
}

int main(void)
{
    //Inicjalizacje
    ioinit();               //Inicjalizujemy wejscia jako wejscia a wyjscia jako wyjscia
    MOTOR_init();           //Inicjalizcja Motora (3, 4, 5 i 6)
    MOTOR34_init();         //Inna inicjalizacja innego motora (3 i 4)
    MOTOR56_init();         //Jeszcze inniejsza inicjalizacja jeszcze inniejszego motora (5 i 6)


    LED1_ON;
    LED2_OFF;
	DDRC = 0x00; //port C jako wej�cie
    PORTC |= 0b00000000; //piny nie podci�gane do rezystor�w
while(1){
    DDRC = 0x00; //port C jako wej�cie
    PORTC |= 0b00000000; //piny nie podci�gane do rezystor�w
    if(PINC == 0b00000001) // ostro prawo
    {
         MOTOR_drive(255,-255);
    }
    else if(PINC==0b00000011) //lekko prawo
    {
         MOTOR_drive(255,0);
    }
    else if(PINC==0b00001100) // lekko lewo
    {
         MOTOR_drive(0,255);
    }
    else if(PINC==0b00001000)  // ostro lewo
    {
         MOTOR_drive(-255,255);
    }
    else if(PINC==0b00001111)  // cala naprz�d
    {
         MOTOR_drive(255,255);
    }
    else if(PINC==0b00001101)  // lekko naprz�d               !!!!!!!!!!!!!!!!!!
    {
         MOTOR_drive(200,200);
    }
    else if(PINC==0b00000110)  // cala wstecz
    {
         MOTOR_drive(-255,-255);
    }
    else if(PINC==0b00001110) //lewo wstecz
    {
        MOTOR_drive(-255,0);
    }
    else if(PINC==0b00000111) //prawo wstecz
    {
        MOTOR_drive(0,-255);
    }
    else
    {
        LED1_OFF;
        LED2_ON;
    }
    return 0;
}
}
