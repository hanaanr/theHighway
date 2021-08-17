/*
Hanaan Shafi
 Final Project
 */

import processing.sound.*;
SoundFile file; //creating file for my sound

import processing.serial.*;
Serial port; // serial connection

import gifAnimation.*;
Gif myAnimation; //this is for the gif image I'm using for the moving road background

PFont font; //setting up font
PImage goopImg; //setting up images of goop, car and reward
PImage carImg;
PImage rewardImg;

int screenNumber = 0; //this determines whether we are at the instructions screen, the game screen or the end screen
int score = 0; //this is the score
float carX; //x coordinate of the car (car can only move horizontally)
boolean moveDown = true; //this is for the incoming goop
boolean hitGoop = false;  //this is used to send data to Arduino about whether or not the goop has been hit
int left = 0; //this is used to receive data from Arduino and determine whether to move the car left or right
int right = 0; 

//the classes Car, Goop and Reward are used to encapsulate their respective properties
Car car; 
Goop goop;
Reward reward;

void setup() {

  size (800, 550);

  file = new SoundFile(this, "mysound.mp3"); //sound
  font = loadFont("Arial-BoldMT-48.vlw"); //font
  myAnimation = new Gif(this, "road.gif"); //gif for background
  myAnimation.play(); //start gif playing

  carImg = loadImage("blue.png");
  goopImg = loadImage("goop2.png");
  rewardImg = loadImage("coin.png");
  car = new Car(350);  
  goop = new Goop(200, 0);
  reward = new Reward(500, 0);

  //initialize serial port
  port = new Serial(this, Serial.list()[2], 9600);
  port.clear();
  port.bufferUntil('\n');
}

void draw() {

  switch(screenNumber) { //this is to switch between the four screens 

  case 0: //instructions screen
    background(255, 236, 139);
    textFont(font);
    textSize(30);
    fill(204, 0, 0);
    text("Welcome to the Highway!", 220, 100);

    textSize(20);
    fill(0);
    text("Instructions:", 200, 160);
    text("1. Your goal is to avoid all the goop puddles", 180, 200);
    text("along the road.", 180, 230);
    text("2. You can move your car to left or right using", 180, 260);
    text("the push buttons on your Arduino circuit. Your", 180, 290);
    text("car cannot move up or down.", 180, 320);
    text("3. For every reward you catch along the way", 180, 350);
    text("your score increases by 1 point.", 180, 380);

    fill(204, 0, 0);
    text("CLICK TO BEGIN!", 300, 450);
    score = 0;
    break;

  case 1:     // this is the actual game, displayed on the game screen 
    image(myAnimation, 0, 0); //display the gif

    car.movingCar();
    goop.incomingGoop();
    reward.incomingReward();

    textFont(font);
    textSize(20);
    text("score:", 30, 50);
    text(score, 100, 50);

    if (score == 10) { //if the user gets a score of ten, then switch to the "good job!" screen
      screenNumber = 3;
    }

    break;

  case 2:     // "you lost" screen
    background(255, 236, 139);
    text("You lost :( ", 350, 250);
    text("Click anywhere to play again!", 250, 330);
    break;

  case 3: //"good job" screen
    background(255, 236, 139);
    text("Good job!", 350, 250);
    break;
  }
}

//you can switch to the next screen upon clicking:
void mousePressed() {
  if (screenNumber == 0) { //click to begin the game
    screenNumber = 1;
  }
  if (screenNumber == 2) { //click to restart once you've won or lost
    screenNumber = 0;
  } 
  if (screenNumber == 3) {
    screenNumber = 0;
  }
}

void serialEvent(Serial port) {
  //read the incoming data from Arduino and split them by comma into integers named left and right
  String s = port.readStringUntil('\n');
  s = trim(s);
  if (s!=null) {
    println(s);
    int values[]=int(split(s, ','));
    if (values.length==2) {
      left = values[0];
      right = values[1];
    }
  }
  port.write(int(score)+ "," + int(hitGoop) + "\n"); //send score and info on whether goop has been hit, to Arduino
}

// this is the class for the goop 
class Goop {

  float goopX; //X coordinate of the goop
  float goopY; //Y coordinate of the goop

  Goop (float temp1, float temp2) {
    goopX = temp1; 
    goopY = temp2;
  }

  void incomingGoop() { //this is the function for the incoming goop

    //image(goopImg, goopX, goopY, 90, 60); //display image of goop at (x, y)
    image(goopImg, goopX, goopY, 90, 60);

    //moveDown is a global variable which is always set to true, so the goop always moves down
    if (moveDown == true) { 
      goopY = goopY + 6; //move down goop by 4 units
    }

    if (goopY <= 500) { //if the goop is still above a certain height close to the bottom of the screen (ie 650), let it continue moving down
      moveDown = true;
    }

    if (goopY > 500) { // if the goop crosses that threshold, then:
      goopY = 0; //reset the goop's Y car back to the top
      goopX = random(30, 670); // change the X position to any random position 
      moveDown = true; //move down
      hitGoop = false;
    }

    if (goopY > 375 && goopX < carX + 50 && goopX > carX - 70) { //if the goop's X and Y coordinates coincide with the that of the car, then:
      screenNumber = 2; //switch to the ending screen ("you lost!") and also do the following to reset the game: 
      goopY = 0; //reset the goop's Y position back to the top
      goopX = random(30, 90);  //change the X position to any random position 
      moveDown = true; //move down
      hitGoop = true;
    }
  }
}

// this is the class for the car
class Car {

  Car(float temp1) {
    carX = temp1; // this is the x coordinate of the car. it is a global variable, because it is referenced in the goop class
  }

  void movingCar() { //ths is the function to move the car left and right

    image(carImg, carX, 400, 80, 150); //display the image of the car
    if (left == 1) { //if LEFT button (on circuit) is pressed, move the car to the left 5 units
      carX = carX - 4*left;
    }
    if (right == 1) { //if RIGHT is pressed, move the car to the right 5 units
      carX = carX + 4*right;
    }
  }
}


//class for reward
class Reward {

  float rewardX; //X coordinate 
  float rewardY; //Y coordinate

  Reward (float temp1, float temp2) {
    rewardX = temp1; 
    rewardY = temp2;
  }

  void incomingReward() { //this is the function for the incoming rewards

    image(rewardImg, rewardX, rewardY, 30, 30);

    //moveDown is a global variable which is always set to true, so the reward always moves down
    if (moveDown == true) { 
      rewardY = rewardY + 6; //move down by 4 units
    }

    if (rewardY <= 500) { //if the reward is still above a certain height, let it continue moving down
      moveDown = true;
    }

    if (rewardY > 500) { // if the reward crosses that threshold, then: 
      rewardY = 0; //reset Y position back to the top
      rewardX = random(30, 800);  //change the X position to any random position 
      moveDown = true; //move down
    }

    if (rewardY > 375 && rewardX < carX + 50 && rewardX > carX - 70) { //if the reward coincides with car, then:
      rewardY = 0; //reset the Y back to the top
      rewardX = random(30, 670); // change the X position to any random position 
      moveDown = true; //move down
      file.play(); // play the sound
      score++; // increase the score by one
    }
  }
}
