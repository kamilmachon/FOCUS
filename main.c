#include <avr/io.h>
#include <util/delay.h>

/*
!!!UWAGA
Aby biblioteka z delayami dzialala nalezy w ustawieniach kompilatora wlaczyc optymalizacje
*/
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
int main(void)
{
    DDRD |= LED1_PIN;       //Ustawienie LEDa 1 jako wyjscie
    DDRD |= LED2_PIN;       //Ustawienie LEDa 2 jako wyjscie
//Tutaj ustawiamy poczatkowe dyrektywy
    LED1_ON;                //LED1 na poczatku wlaczony
    LED2_OFF;               //LED2 na poczatku wylaczony
//W petli umieszczamy program wykonywany caly czas
    while(1)
    {
        //Migamy LEDem 1 3 razy krotko, LEDem 2 3 razy dlugo, LEDem 1 3 razy krotko, 0,5s pzerwy
        LED1_ON;
        _delay_ms(100); //Opoznienie w ms
        LED1_OFF;
        _delay_ms(100);
        LED1_ON;
        _delay_ms(100);
        LED1_OFF;
        _delay_ms(100);
        LED1_ON;
        _delay_ms(100);
        LED1_OFF;
        _delay_ms(100);
        LED2_ON;
        _delay_ms(300);
        LED2_OFF;
        _delay_ms(100);
        LED2_ON;
        _delay_ms(300);
        LED2_OFF;
        _delay_ms(100);
        LED2_ON;
        _delay_ms(300);
        LED2_OFF;
        _delay_ms(100);
        LED1_ON;
        _delay_ms(100);
        LED1_OFF;
        _delay_ms(100);
        LED1_ON;
        _delay_ms(100);
        LED1_OFF;
        _delay_ms(100);
        LED1_ON;
        _delay_ms(100);
        LED1_OFF;
        _delay_ms(500);
    }
}
