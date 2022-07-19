//---Inspiration---
//Pop Music is Stuck on Repeat | Colin Morris | TEDxPenn
//https://www.youtube.com/watch?v=_tjFwcmHy5M
//-----------------
//Web-version from someone else:
//https://song-visualizer.firebaseapp.com/intro
//-----------------

import java.util.Map;
import java.util.ArrayList;
String[][] save;
HashMap<String, int[]> colorhashmap;
String[][] matrix;
int colorshift = 0;

void setup() {
  String[] file = loadStrings("lyrics.txt");
  String[] lyrics = words(file, true);
  matrix = genMatrix(lyrics);
  size(1000, 1000);
  colorhashmap = genHashmap(words(file, true));
  colorMode(HSB);
  background(20);
  drawMatrix(matrix, colorhashmap);
  //filter(INVERT);
  for(int i = 0; i<2;i++) {
    applyBlur(3);
    drawMatrix(matrix, colorhashmap);
    //filter(INVERT);
    println("Applied filter: " + (i+1) + " times.");
  }
  frameRate(24);
  saveImage();
}

void draw() {
  //background(20);
  colorshift+=1;
  //drawMatrix(matrix, colorhashmap);
}

void drawMatrix(String[][] a, HashMap<String, int[]> colormap) {
  float x = a[0].length;
  float y = a[0].length;
  println(x);
  float abstand = 0f;
  float xsize = (float(width)/x)-abstand;
  float ysize = (float(height)/y)-abstand;
  println("ysize: " + ysize + " xsize: "+xsize);
  noStroke();
  for (int i = 0; i<x; i++) {
    for (int k = 0; k<y; k++) {
      textAlign(CENTER);
      int[] colorattr=colormap.get(a[i][k]);
      if (colorattr[1]!=0) {
        fill(color((colorattr[0]+colorshift)%255, 255, colorattr[1]));
        rect((float(width)/x)*i, (float(height)/y)*k, xsize, ysize);
      }
      //fill(255);
      //strokeWeight(0.25f);
      if ((height/y) >= 20 && (width/x) >= 60) {
       //text(a[i][k], ((width/x)*i)+(xsize/2), ((height/y)*k)+(ysize/2)+abstand);
      }
    }
  }
  println("Analyse fertiggestellt.");
  
}
void applyBlur(int a) {
  filter(BLUR, a);
}
void saveImage() {
  save("test.png");
}

HashMap<String, int[]> genHashmap(String[] lyrics) {
  HashMap<String, int[]> output = new HashMap<String, int[]>();
  println("Vorher: "+lyrics.length);
  lyrics = uniqueLyrics(lyrics);
  println("Nachher: " + lyrics.length);
  float colorstep = 255f/float(lyrics.length);
  for (int i = 0; i<lyrics.length; i++) {
    int colour = int(colorstep*i);
    if (output.get(lyrics[i])==null) {
      int brightness=255;
      int[] colorattr = {colour, brightness};
      output.put(lyrics[i], colorattr);
      println("Wort: " + lyrics[i] + " Farbe: " + colour);
    }
  }
  int[] blank = {0, 0};
  output.put("nullpe", blank);
  return output;
}

String[] uniqueLyrics(String[] lyrics) {

  ArrayList<String> list = new ArrayList<String>();
  for (int i = 0; i<lyrics.length; i++) {
    Boolean testin = false;
    for (int j = 0; j<list.size(); j++) {
      if (lyrics[i].equals(list.get(j))) {
        testin = true;
      }
    }
    if (!testin) {
      list.add(lyrics[i]);
    }
  }
  String[] output = new String[list.size()];
  for (int i = 0; i<list.size(); i++) {
    output[i]=list.get(i);
  }
  return list.toArray(new String[0]);
}
String[][] genMatrix(String[] lyrics) {
  String[][] output = new String[lyrics.length][lyrics.length];
  int lengthl = lyrics.length;
  for (int i = 0; i<lengthl; i++) {
    for (int j = 0; j<lengthl; j++) {
      if (lyrics[i].equals(lyrics[j])) {
        output[i][j]=lyrics[i];
      } else {
        output[i][j]="nullpe";
      }
    }
  }

  //output = removeSingles(output);
  return output;
}
String[][] removeSingles(String[][] input) {
  for (int i = 0;i<input.length-1;i++) {
    for (int j = 0;j<input[0].length-1;j++) {
      if(!input[i][j].equals("nullpe")) { //aktueller Pixel ist gefüllt
        if(input[i+1][j+1].equals("nullpe")) { //Pixel unten rechts ist nicht gefüllt.
          if(i>0&&j>0&&input[i-1][j-1].equals("nullpe")) { //Pixel oben links ist nicht gefüllt.
            input[i][j] = "nullpe";
          } else if(i==0 || j==0) {
            input[i][j] = "nullpe";
          }
        }
      }
    }
  }
  return input;
}
String[] removeDoubleLyrics(String[] lyrics) {
  ArrayList<String> list = new ArrayList<String>();
  for (int i = 0; i<lyrics.length-1; i++) {
    if(!lyrics[i].equals(lyrics[i+1])) {
      list.add(lyrics[i]);
    }
  }
  return list.toArray(new String[0]);
}
String[] words(String[] input, Boolean mode) {
  String output = "";
  for (int i = 0; i<input.length; i++) {
    String between = trim(input[i]);
    output=output + between + " ";
  }
  //println(output);
  output = trim(output).toLowerCase();
  if (mode) {
    output = cleartext(output);
    println(output);
  }

  String[] outputa = split(output, " ");
  for (int i = 0; i<outputa.length; i++) {
    outputa[i]=trim(outputa[i]);
  }
  return outputa;
}
String cleartext(String textv) {
  textv=textv.toLowerCase();
  textv=replaceauo(textv);
  for (int i=0; i<textv.length(); i++) {
    if (!((int(textv.charAt(i))<123 && int(textv.charAt(i))>96)|| textv.charAt(i)==32) ) {
      textv = textv.substring(0, i) + textv.substring(i+1, textv.length());
      i--;
    }
  }
  return textv;
}
String replaceauo(String text) {
  String[] original = {"ä", "ö", "ü", "à", "á", "â", "ã", "è", "é", "ê", "ë", "ß"};
  String[] replace = {"ae", "oe", "ue", "a", "a", "a", "a", "e", "e", "e", "e", "ss"};
  for (int i =0; i<original.length; i++) {
    text=text.replace(original[i], replace[i]);
  }
  return text;
}
void output(String[] array) {
  for (int i = 0; i<array.length; i++) {
    println(i+": "+array[i]);
  }
}
void output2dtxt(String[][] array) {
  for (int i = 0; i<array[0].length; i++) {
    String output = "";
    for (int j = 0; j<array[i].length; j++) {
      output=output+array[i][j];
    }
    println(i+": "+output);
  }
}
