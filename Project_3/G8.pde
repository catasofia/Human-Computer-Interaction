// Bakeoff #3 - Escrita de Texto em Smartwatches
// IPM 2019-20, Semestre 2
// Entrega: exclusivamente no dia 22 de Maio, até às 23h59, via Discord

// Processing reference: https://processing.org/reference/

import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

// Screen resolution vars;
float PPI, PPCM;
float SCALE_FACTOR;

// Finger parameters
PImage fingerOcclusion;
int FINGER_SIZE;
int FINGER_OFFSET;

// Arm/watch parameters
PImage arm;
int ARM_LENGTH;
int ARM_HEIGHT;


// Study properties
String[] phrases;                   // contains all the phrases that can be tested
int NUM_REPEATS            = 2;     // the total number of phrases to be tested
int currTrialNum           = 0;     // the current trial number (indexes into phrases array above)
String currentPhrase       = "";    // the current target phrase
String currentTyped        = "";    // what the user has typed so far
String currentWord         = "";    // current word written by the user
String[] allWords;                  // contains all the words from the file with 333333 most used words;
String wordPred;                    // the current predicted word
String[] typed = new String[NUM_REPEATS];


char lastChar = '<';               //variable just to know if the last character was a ' ', just because of the predicted word
String lastPred = "";
String word = "";

PImage green_check;
PImage delete;
PImage arrow_left;
PImage arrow_right;
PImage space;

// Performance variables
float startTime            = 0;     // time starts when the user clicks for the first time
float finishTime           = 0;     // records the time of when the final trial ends
float lastTime             = 0;     // the timestamp of when the last trial was completed
float lettersEnteredTotal  = 0;     // a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0;     // a running total of the number of letters expected (correct phrases)
float errorsTotal          = 0;     // a running total of the number of errors (when hitting next)


char[] letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};   //first keyboard that appears;
char lastCharKey = 'g';                                 // last char from the keyboard;

//Setup window and vars - runs once
void setup()
{
  //size(900, 900);
  fullScreen();
  textFont(createFont("Arial", 24));  // set the font to arial 24
  noCursor();                         // hides the cursor to emulate a watch environment
  
  // Load images
  arm = loadImage("arm_watch.png");
  fingerOcclusion = loadImage("finger.png");
  green_check = loadImage("green_check.png");
  delete = loadImage("delete.png");
  arrow_left = loadImage("arrow_left.png");
  arrow_right = loadImage("arrow_right.png");
  space = loadImage("space.png");
  
  // Load phrases
  phrases = loadStrings("phrases.txt");                       // load the phrase set into memory
  allWords = loadStrings("allWords.txt");                     //load the text file
  Collections.shuffle(Arrays.asList(phrases), new Random());  // randomize the order of the phrases with no seed
  
  // Scale targets and imagens to match screen resolution
  SCALE_FACTOR = 1.0 / displayDensity();          // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");   // the text from the file is loaded into an array.
  PPI = float(ppi_string[1]);                     // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM = PPI / 2.54 * SCALE_FACTOR;               // do not change this!
  
  FINGER_SIZE = (int)(11 * PPCM);
  FINGER_OFFSET = (int)(0.8 * PPCM);
  ARM_LENGTH = (int)(19 * PPCM);
  ARM_HEIGHT = (int)(11.2 * PPCM);
  
}

void draw()
{ 
  // Check if we have reached the end of the study
  if (finishTime != 0)  return;
 
  background(255);                                                         // clear background
  
  // Draw arm and watch background
  imageMode(CENTER);
  image(arm, width/2, height/2, ARM_LENGTH, ARM_HEIGHT);
  
  // Check if we just started the application
  if (startTime == 0 && !mousePressed)
  {
    fill(0);
    textAlign(CENTER);
    text("Tap to start time!", width/2, height/2);
    
    //to inform the user of the keys in the keyboard
    text("Selecionar palavra prevista", 4.35*PPCM, 1.3*PPCM);
    image(green_check, 1.4*PPCM, 1.15*PPCM, 0.7*PPCM, 0.7*PPCM);
    
    text("Apagar última letra escrita", 4.27*PPCM, 2.4*PPCM);
    image(delete, 1.4*PPCM, 2.3*PPCM, 0.8*PPCM, 0.8*PPCM);
    
    text("Introduzir um espaço", 3.85*PPCM, 3.5*PPCM);
    image(space, 1.4*PPCM, 3.4*PPCM, 0.8*PPCM, 0.8*PPCM);
    
  }
  else if (startTime == 0 && mousePressed) {
  
    nextTrial();                    // show next sentence
    
  }
  // Check if we are in the middle of a trial
  else if (startTime != 0)
  {
    textAlign(LEFT);
    fill(100);
    text("Phrase " + (currTrialNum + 1) + " of " + NUM_REPEATS, width/2 - 4.0*PPCM, height/2 - 8.1*PPCM);   // write the trial count
    text("Target:    " + currentPhrase, width/2 - 4.0*PPCM, height/2 - 7.1*PPCM);                           // draw the target string
    fill(0);
    text("Entered:  " + currentTyped + "|", width/2 - 4.0*PPCM, height/2 - 6.1*PPCM);                      // draw what the user has entered thus far 
    
    // Draw very basic ACCEPT button - do not change this!
    textAlign(CENTER);
    noStroke();
    fill(0, 250, 0);
    rect(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM);
    fill(0);
    text("ACCEPT >", width/2, height/2 - 4.1*PPCM);


    text("Selecionar palavra prevista", 4.35*PPCM, 1.3*PPCM);
    image(green_check, 1.4*PPCM, 1.15*PPCM, 0.7*PPCM, 0.7*PPCM);
    
    text("Apagar última letra escrita", 4.27*PPCM, 2.4*PPCM);
    image(delete, 1.4*PPCM, 2.3*PPCM, 0.8*PPCM, 0.8*PPCM);
    
    text("Introduzir um espaço", 3.85*PPCM, 3.5*PPCM);
    image(space, 1.4*PPCM, 3.4*PPCM, 0.8*PPCM, 0.8*PPCM);
    

    // Draw screen areas
    // simulates text box - not interactive
    noStroke();
    fill(125);
    rect(width/2 - 2.0*PPCM, height/2 - 2.0*PPCM, 4.0*PPCM, 1.0*PPCM);
    textAlign(CENTER);
    fill(0);
    textFont(createFont("Arial", 0.6*PPCM));
    
    // THIS IS THE ONLY INTERACTIVE AREA (4cm x 4cm); do not change size
    
    stroke(0, 255, 0);
    noFill();
    rect(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM);
    
    // Write current letter
    textAlign(CENTER);
    fill(0);

    //draw the keyboard
    if(startTime != 0)
    {
      drawKeyboard(letters);
      if(currentWord.isEmpty()) word = getPredWord("");
      text("" + word, width/2, height/2 - 1.3 * PPCM); 
      textFont(createFont("Arial", 24));    
    }
    
    fill(255);
    rect(width/2 - 2.0*PPCM, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    image(arrow_left, width/2 - 1.5*PPCM, height/2 + 1.5*PPCM, 1.0*PPCM, 1.0*PPCM);
    
    fill(255);
    rect(width/2 - 1.0*PPCM, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    image(space, width/2 - 0.5*PPCM, height/2 + 1.5*PPCM, 0.8*PPCM, 0.8*PPCM);
    
    fill(255);
    rect(width/2, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    image(green_check, width/2 + 0.5*PPCM, height/2 + 1.5*PPCM, 0.8*PPCM, 0.8*PPCM);
    
    fill(255);
    rect(width/2 + 1.0*PPCM, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    image(arrow_right, width/2 + 1.5*PPCM, height/2 + 1.5*PPCM, 1.0*PPCM, 1.0*PPCM);
        
    fill(255);
    rect(width/2 + 1.0*PPCM, height/2, 1.0*PPCM, 1.0*PPCM);
    image(delete, width/2 + 1.5*PPCM, height/2 + 0.5*PPCM, 1.0*PPCM, 1.0*PPCM);
    
  }

  // Draw the user finger to illustrate the issues with occlusion (the fat finger problem)
  imageMode(CORNER);
  image(fingerOcclusion, mouseX - FINGER_OFFSET, mouseY - FINGER_OFFSET, FINGER_SIZE, FINGER_SIZE);
}

//function that predicts the word
//goes to the file count_1w.txt from norvig.com and gets the first word that starts with the letters entered by the user
//if nothing was written, ir returns the first word (the)
String getPredWord(String writtenWord){
  for(int i = 0; i < 333333; i++){
    if (allWords[i].startsWith(writtenWord)){
      String[] word = split(allWords[i], '\t'); 
      return word[0];
    }
  }
  return "";
}


void drawKeyboard(char[] letters){
    fill(#FFFFFF);
    rect(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[0], width/2 - 1.5*PPCM, height/2 - 0.3*PPCM);
    
    fill(#FFFFFF);
    rect(width/2 - 1.0*PPCM, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[1], width/2 - 0.5*PPCM, height/2 - 0.3*PPCM);
    
    fill(#FFFFFF);
    rect(width/2, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[2], width/2 + 0.5*PPCM, height/2 - 0.3*PPCM);
    
    fill(#FFFFFF);
    rect(width/2 + 1.0*PPCM, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[3], width/2 + 1.5*PPCM, height/2 - 0.3*PPCM);
    
    fill(#FFFFFF);
    rect(width/2 - 2.0*PPCM, height/2, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[4], width/2 - 1.5*PPCM, height/2 + 0.7*PPCM);
    
    fill(#FFFFFF);
    rect(width/2 - 1.0*PPCM, height/2, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[5], width/2 - 0.5*PPCM, height/2 + 0.7*PPCM);
    
    fill(#FFFFFF);
    rect(width/2, height/2, 1.0*PPCM, 1.0*PPCM);
    fill(#000000);
    text(""+letters[6], width/2 + 0.5*PPCM, height/2 + 0.7*PPCM);
}




// Check if mouse click was within certain bounds
boolean didMouseClick(float x, float y, float w, float h)
{
  return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
}




void mousePressed()
{
  // Test click on 'accept' button - do not change this!
  if (didMouseClick(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM)) nextTrial();
  
  else if(didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM))  // Test click on 'keyboard' area - do not change this condition! 
  {  
    // Test click on right arrow, moves to the next keyboard;
    if (didMouseClick(width/2 + 1.0*PPCM, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM))
    {
      if (lastCharKey == 'g'){
        char[] letters1 = {'h', 'i', 'j','k','l', 'm','n'};
        letters = letters1;
        lastCharKey = 'n';
      }
      
      else if(lastCharKey == 'n'){
        char[] letters1 = {'o', 'p', 'q','r','s', 't','u'};
        letters = letters1;
        lastCharKey = 'u';
      }
      
      else if(lastCharKey == 'u'){
        char[] letters1 = {'v', 'w', 'x','y','z', ' ',' '};
        letters = letters1;
        lastCharKey = 'z';
      }
      
      else if(lastCharKey == 'z'){
        char[] letters1 = {'a', 'b', 'c','d','e', 'f','g'};
        letters = letters1;
        lastCharKey = 'g';
      }
    }
  
    // Test click on left arrow, moves to the previous keyboard;
    if (didMouseClick(width/2 - 2.0*PPCM, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM))
    {
      if (lastCharKey == 'g'){
        char[] letters1 = {'v', 'w', 'x','y','z', ' ',' '};
        letters = letters1;
        lastCharKey = 'z';
      }
      
      else if(lastCharKey == 'n'){
        char[] letters1 = {'a', 'b', 'c','d','e', 'f','g'};
        letters = letters1;
        lastCharKey = 'g';
      }
      
      else if(lastCharKey == 'u'){
        char[] letters1 = {'h', 'i', 'j','k','l', 'm','n'};
        letters = letters1;
        lastCharKey = 'n';
      }
      
      else if(lastCharKey == 'z'){
        char[] letters1 = {'o', 'p', 'q','r','s', 't','u'};
        letters = letters1;
        lastCharKey = 'u';
      }
    }
    
    
    //Test click on the accept predicted word key;
    //Adds the word written to the current typed and cleans the word;
    else if(didMouseClick(width/2, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM)){
        currentTyped = currentTyped.substring(0, currentTyped.length() - currentWord.length());
        currentTyped += word + " ";
        lastPred = word;
        lastChar = ' ';
        word = word.substring(0, word.length() - word.length());
        currentWord = currentWord.substring(0, currentWord.length() - currentWord.length()); 
  }
    
    // Test click on a letter key, adds to the word written and to the currentTyped;
    //Always predicting a new word, based on what the user typed;
    else if(didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM)){
      currentWord += letters[0];
      currentTyped += letters[0];
      word = getPredWord(currentWord);
      lastChar='<';  
    }
    
    // Test click on a letter key, adds to the word written and to the currentTyped;
    //Always predicting a new word, based on what the user typed;
    else if(didMouseClick(width/2 - 1.0*PPCM, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM)){
      currentWord += letters[1];
      currentTyped += letters[1];
      word = getPredWord(currentWord);
      lastChar='<';
    }
    
    // Test click on a letter key, adds to the word written and to the currentTyped;
    //Always predicting a new word, based on what the user typed;
    else if(didMouseClick(width/2, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM)){
      currentWord += letters[2];
      currentTyped += letters[2];
      word = getPredWord(currentWord);
      lastChar='<';
    }
    
    // Test click on a letter key, adds to the word written and to the currentTyped;
    //Always predicting a new word, based on what the user typed;
    else if(didMouseClick(width/2 + 1.0*PPCM, height/2 - 1.0*PPCM, 1.0*PPCM, 1.0*PPCM)){
      currentWord += letters[3];
      currentTyped += letters[3];
      word = getPredWord(currentWord);
      lastChar='<';
    }
    
    else if(didMouseClick(width/2 - 2.0*PPCM, height/2, 1.0*PPCM, 1.0*PPCM)){
      currentWord += letters[4];
      currentTyped += letters[4];
      word = getPredWord(currentWord);
      lastChar='<';
    }
    
    // Test click on a letter key, adds to the word written and to the currentTyped;
    //Always predicting a new word, based on what the user typed;
    else if(didMouseClick(width/2 - 1.0*PPCM, height/2, 1.0*PPCM, 1.0*PPCM)){
      if(lastCharKey != 'z'){
        currentWord += letters[5];
        currentTyped += letters[5];
        word = getPredWord(currentWord);
        lastChar='<';
      }
      
    }
    
    // Test click on a letter key, adds to the word written and to the currentTyped;
    //Always predicting a new word, based on what the user typed;
    else if(didMouseClick(width/2, height/2, 1.0*PPCM, 1.0*PPCM)){
      if(lastCharKey != 'z'){
        currentWord += letters[6];
        currentTyped += letters[6];
        word = getPredWord(currentWord);
        lastChar='<';
      }
    }
    
    
    
    // Test click on space key, cleans word written and adds a space to the currentTyped;
    else if(didMouseClick(width/2 - 1.0*PPCM, height/2 + 1.0*PPCM, 1.0*PPCM, 1.0*PPCM)){
        lastPred = currentWord;
        lastChar = ' ';
        currentWord = currentWord.substring(0, currentWord.length() - currentWord.length());
        word = word.substring(0, word.length() - word.length());
        currentTyped+=" ";
    }
     
      
    // Test click on delete key, cleans the last char of the word and of the currentTyped;
    else if(didMouseClick(width/2 + 1.0*PPCM, height/2, 1.0*PPCM, 1.0*PPCM) && (currentTyped.length() > 0)){
      if (currentWord.length() > 0){
      
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
        currentWord = currentWord.substring(0, currentWord.length() - 1);
        if(lastChar == ' '){
          word = getPredWord(lastPred);
 
        }
        else word = getPredWord(currentWord);
      }
      else{
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
          currentWord = lastPred;
          word = getPredWord(lastPred); 
      }
    }  
  }
  else System.out.println("debug: CLICK NOT ACCEPTED");
}


void nextTrial()
{
  if (currTrialNum >= NUM_REPEATS) return;                                            // check to see if experiment is done
  
  // Check if we're in the middle of the tests
  else if (startTime != 0 && finishTime == 0)                                         
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + NUM_REPEATS);
    System.out.println("Target phrase: " + currentPhrase);
    System.out.println("Phrase length: " + currentPhrase.length());
    System.out.println("User typed: " + currentTyped);
    System.out.println("User typed length: " + currentTyped.length());
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim()));
    System.out.println("Time taken on this trial: " + (millis() - lastTime));
    System.out.println("Time taken since beginning: " + (millis() - startTime));
    System.out.println("==================");
    lettersExpectedTotal += currentPhrase.trim().length();
    lettersEnteredTotal += currentTyped.trim().length();
    errorsTotal += computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
    typed[currTrialNum] = currentTyped;
  }
  
  // Check to see if experiment just finished
  if (currTrialNum == NUM_REPEATS - 1)                                           
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime));
    System.out.println("Total letters entered: " + lettersEnteredTotal);
    System.out.println("Total letters expected: " + lettersExpectedTotal);
    System.out.println("Total errors entered: " + errorsTotal);

    float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f);   // FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal * .05;                                 // no penalty if errors are under 5% of chars
    float penalty = max(0, (errorsTotal - freebieErrors) / ((finishTime - startTime) / 60000f));
    float cps = (lettersEnteredTotal) / ((finishTime - startTime) / 1000f);           //calculates the character per seconds - 1K is number of milliseconds  in one second
    
    
    System.out.println("Raw WPM: " + wpm);
    System.out.println("Freebie errors: " + freebieErrors);
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm - penalty));                         // yes, minus, because higher WPM is better: NET WPM
    System.out.println("==================");
    
    printResults(wpm, freebieErrors, penalty, cps);
    
    currTrialNum++;                                                                   // increment by one so this mesage only appears once when all trials are done
    return;
  }

  else if (startTime == 0)                                                            // first trial starting now
  {
    System.out.println("Trials beginning! Starting timer...");
    startTime = millis();                                                             // start the timer!
  } 
  else currTrialNum++;                                                                // increment trial number

  lastTime = millis();                                                                // record the time of when this trial ended
  currentTyped = "";                                                                  // clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum];                                              // load the next phrase!
  currentWord = "";                                                                   
  word = "";
}

// Print results at the end of the study
void printResults(float wpm, float freebieErrors, float penalty, float cps)
{
  background(0);       // clears screen
  
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen
  
  text("Finished!", width / 2, height / 2); 
  
  int h = 20;
  for(int i = 0; i < NUM_REPEATS; i++, h += 40 ) {
    text("Target phrase " + (i+1) + ": " + phrases[i], width / 2, height / 2 + h);
    text("User typed " + (i+1) + ": " + typed[i], width / 2, height / 2 + h+20);
  }
  
  text("Raw WPM: " + wpm, width / 2, height / 2 + h+20);
  text("Freebie errors: " + freebieErrors, width / 2, height / 2 + h+40);
  text("Penalty: " + penalty, width / 2, height / 2 + h+60);
  text("WPM with penalty: " + max((wpm - penalty), 0), width / 2, height / 2 + h+80);
  text("Characters per Second: " + cps, width / 2, height / 2  + h + 100);

  saveFrame("results-######.png");    // saves screenshot in current folder    
}

// This computes the error between two strings (i.e., original phrase and user input)
int computeLevenshteinDistance(String phrase1, String phrase2)
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++) distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++) distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
