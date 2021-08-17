//set up LCD
#include <LiquidCrystal.h>
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  lcd.begin(16, 2);
  pinMode(10, OUTPUT);
  pinMode(9, INPUT);
  pinMode(8, INPUT);
  Serial.begin(9600);
  Serial.println("0");
}

void loop() {
  while (Serial.available()) {
    //get score and ledOnOff signal from Processing
    int scoreFromProcessing = Serial.parseInt();
    int ledOnOff = Serial.parseInt();

    if (Serial.read() == '\n') {

      lcd.setCursor(0, 0);
      lcd.print("Score:");

      //if the score is less than 10, then print the score and a space right after it
      if (scoreFromProcessing < 10) {
        lcd.setCursor(6, 0);
        lcd.print(scoreFromProcessing);
        lcd.setCursor(7, 0);
        lcd.print(" ");
      }
      //if the score is not less than 10, then print the score
      else {
        lcd.setCursor(6, 0);
        lcd.print(scoreFromProcessing);
      }

      digitalWrite(10, ledOnOff);

      //now send data to Processing
      int rightButton = digitalRead(9);
      int leftButton = digitalRead(8);
      Serial.print(leftButton);
      Serial.print(',');
      Serial.println(rightButton);

    }
  }
}
