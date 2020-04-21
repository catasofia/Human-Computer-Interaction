// Bakeoff #2 - Seleção de Alvos e Fatores Humanos //<>// //<>//
// IPM 2019-20, Semestre 2
// Bake-off: durante a aula de lab da semana de 20 de Abril
// Submissão via Twitter: exclusivamente no dia 24 de Abril, até às 23h59

// Processing reference: https://processing.org/reference/

import java.util.Collections;
import processing.sound.*;

// Target properties
float PPI, PPCM;
float SCALE_FACTOR;
float TARGET_SIZE;
float TARGET_PADDING, MARGIN, LEFT_PADDING, TOP_PADDING;

float ellipseSize;


SoundFile sound;    //variable to save the sound file that plays in success


// Study properties
ArrayList<Integer> trials  = new ArrayList<Integer>();    // contains the order of targets that activate in the test
int trialNum               = 0;                           // the current trial number (indexes into trials array above)
final int NUM_REPEATS      = 3;                           // sets the number of times each target repeats in the test - FOR THE BAKEOFF NEEDS TO BE 3!
boolean ended              = false;

float[] indexes;         //contains the indexes for each target;
Boolean[] hit;           //contains if each target was hit correctly; 


// Performance variables
int startTime              = 0;      // time starts when the first click is captured
int finishTime             = 0;      // records the time of the final click
int hits                   = 0;      // number of successful clicks
int misses                 = 0;      // number of missed clicks


// Class used to store properties of a target
class Target
{
  int x, y;
  float w;
  
  Target(int posx, int posy, float twidth) 
  {
    x = posx;
    y = posy;
    w = twidth;
  }
}


// Setup window and vars - runs once
void setup()  
{
  //size(900, 900);    // window size in px (use for debugging)
  fullScreen();   // USE THIS DURING THE BAKEOFF!
  
  SCALE_FACTOR    = 1.0 / displayDensity();            // scale factor for high-density displays
  // The text from the file is loaded into an array. 
  String[] ppi_string = loadStrings("ppi.txt");
  PPI = float(ppi_string[1]);      // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM           = PPI / 2.54 * SCALE_FACTOR;     // do not change this!
  TARGET_SIZE    = 1.5 * PPCM;     // set the target size in cm; do not change this!
  TARGET_PADDING = 1.5 * PPCM;     // set the padding around the targets in cm; do not change this!
  MARGIN         = 1.5 * PPCM;     // set the margin around the targets in cm; do not change this!
  LEFT_PADDING   = width/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;        // set the margin of the grid of targets to the left of the canvas; do not change this!
  TOP_PADDING    = height/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;       // set the margin of the grid of targets to the top of the canvas; do not change this!
  
  hit = new Boolean[48];
  indexes = new float[48];
  
  sound = new SoundFile(this,"som.mp3");
  
  noStroke();        // draw shapes without outlines
  frameRate(60);     // set frame rate
  
  // Text and font setup
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  textAlign(CENTER);                    // align text
  
  randomizeTrials();    // randomize the trial order for each participant
 
}


// Updates UI - this method is constantly being called and drawing targets
void draw()
{
  if(hasEnded()) return; // nothing else to do; study is over
    
  background(0);       // set background to black

  // Print trial count
  fill(255);          // set text fill color to white
  text("Trial " + (trialNum + 1) + " of " + trials.size(), 50, 20);    // display what trial the participant is on (the top-left corner)
  text("Green blinking -> current target // Red stroke -> next target", 215,40);
  
  noCursor();  
  
  
  // Draw targets
  for (int i = 0; i < 16; i++) drawTarget(i);
  
  
 
  fill(255);
  ellipse(mouseX, mouseY, PPCM, PPCM);            //draws a white ellipse around the mouse position
  ellipseSize = PPCM;                            
 
  
  for(int i = 0; i < 48; i++){
  Target target = getTargetBounds(trials.get(i));
    //when the mouse is near any target, the ellipse gets bigger 
    if(dist(target.x, target.y, mouseX, mouseY) < target.w * 1.2){
      ellipse(mouseX, mouseY, 1.2*PPCM, 1.2*PPCM);
      fill(255);
      ellipseSize = 1.2*PPCM;
    }else{
       ellipseSize = PPCM;
    }
  }
}
  
  

boolean hasEnded() {
  if(ended) return true;    // returns if test has ended before
   
  // Check if the study is over
  if (trialNum >= trials.size())
  {
    float timeTaken = (finishTime-startTime) / 1000f;     // convert to seconds - DO NOT CHANGE!
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);    // calculate penalty - DO NOT CHANGE!
    
    printResults(timeTaken, penalty);    // prints study results on-screen
    ended = true;
  }
  
  return ended;
}


// Randomize the order in the targets to be selected
// DO NOT CHANGE THIS METHOD!
void randomizeTrials()
{
  for (int i = 0; i < 16; i++)             // 4 rows times 4 columns = 16 target
    for (int k = 0; k < NUM_REPEATS; k++)  // each target will repeat 'NUM_REPEATS' times
      trials.add(i);
  Collections.shuffle(trials);             // randomize the trial order
  
  System.out.println("trial order: " + trials);    // prints trial order - for debug purposes
}

// Print results at the end of the study
void printResults(float timeTaken, float penalty)
{
  background(0);       // clears screen
  
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second() , 100, 20);   // display time on screen
  
  text("Finished!", width / 2, height / 8); 
  text("Hits: " + hits, width / 2, height /8 + 20);
  text("Misses: " + misses, width / 2, height / 8 + 40);
  text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 8 + 60);
  text("Total time taken: " + timeTaken + " sec", width / 2, height / 8 + 80);
  text("Average time for each target: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 8 + 100);
  text("Average time for each target + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 8 + 140);
  text("First Index of Performance", width / 2, height / 8 + 180);
  
  text("Target 1: ---", width / 2.4, height / 8 + 220);
  int h = 20;
  
  for(int i = 2; i <= 24; i++){
    if(hit[i - 1]){
      text("Target " + i + ": " + nf(indexes[i-1],0,3) , width / 2.4, height / 8 + 220 + h);
    }
    else{
      text("Target " + i + ": MISSED", width / 2.4, height / 8 + 220 + h);
    }
    h += 20;
  }
  
  h = 20;
  
  for(int i = 25; i <= 48; i++){
    if(hit[i - 1]){
      text("Target " + i + ": " + nf(indexes[i-1],0,3) , width / 1.7, height / 8 + 200 + h);
    }
    else{
      text("Target " + i + ": MISSED", width / 1.7, height / 8 + 200 + h);
    }
    h += 20;
  }
  
  saveFrame("results-######.png");    // saves screenshot in current folder
}


// Mouse button was released - lets test to see if hit was in the correct target
void mouseReleased() 
{
  if (trialNum >= trials.size()) return;      // if study is over, just return
  if (trialNum == 0) startTime = millis();    // check if first click, if so, start timer
  if (trialNum == trials.size() - 1)          // check if final click
  {
    finishTime = millis();    // save final timestamp
    println("We're done!");
  }
  
  Target target = getTargetBounds(trials.get(trialNum));    // get the location and size for the target in the current trial
  
  // Check to see if the ellipse is inside the target bounds
  if(dist(target.x, target.y, mouseX, mouseY) < ((target.w/2) + (ellipseSize/2))){
    hit[trialNum] = true;
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime));     // success - hit!
    hits++; // increases hits counter 
    sound.play();
  }
  else
  {
    hit[trialNum] = false; 
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime));  // fail
    misses++;   // increases misses counter
  }
  trialNum++;   // move on to the next trial; UI will be updated on the next draw() cycle
  if(trialNum < 48){
    Target newTarget = getTargetBounds(trials.get(trialNum));
    
    float dist = dist(mouseX, mouseY, newTarget.x, newTarget.y);
    float index = log(dist/TARGET_SIZE + 1)/log(2);              //calculates the index -> logb(a) = log(a)/log(b)
    
    indexes[trialNum] = index;
  }
}  


// For a given target ID, returns its location and size
Target getTargetBounds(int i)
{
  int x = (int)LEFT_PADDING + (int)((i % 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  int y = (int)TOP_PADDING + (int)((i / 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  
  return new Target(x, y, TARGET_SIZE);
}

// Draw target on-screen
// This method is called in every draw cycle; you can update the target's UI here
void drawTarget(int i)
{
  Target target = getTargetBounds(i);   // get the location and size for the circle with ID:i
  fill(120,120,120);           // fill dark gray
  // check whether current circle is the intended target
  if (trials.get(trialNum) == i) 
  { 
    // if so ...
    fill(0,255,0,255-map(millis()%850,165,20,90,55));    //the current target is blinking with a green colour
    stroke(0,255,0);       // stroke green
    strokeWeight(2);   // stroke weight 2 
    circle(target.x, target.y, target.w);
  }
  
  if((trialNum < 47) && (trials.get(trialNum + 1) == i)) stroke(255,0,0);    //the next target has a red stroke
  
  alpha(100);
  circle(target.x, target.y, target.w);   // draw target
  
  noStroke();    // next targets won't have stroke (unless it is the intended target)
}
