//---Inspiration---
//Pop Music is Stuck on Repeat | Colin Morris | TEDxPenn
//https://www.youtube.com/watch?v=_tjFwcmHy5M
//-----------------
//Web-version from someone else:
//https://song-visualizer.firebaseapp.com/intro
//-----------------

import java.util.ArrayList;
String[][] save;
HashMap<String, int[]> colorhashmap;
String[][] matrix;
int colorshift = 0; // used for shifting colors around

void setup() {
  String[] file = loadStrings("lyrics.txt");
  String[] lyrics = words(file, true);
  matrix = genMatrix(lyrics);
  size(1000, 1000);
  colorhashmap = genHashmap(lyrics);
  colorMode(HSB);
  //output2dtxt(matrix);
  save2dtxt(matrix);
  background(20);
  drawMatrix(matrix, colorhashmap);

  //This creates the blur-effect while having a sharp center for all significent pixels
  for (int i = 0; i<2; i++) {
    applyBlur(3);
    println("Applied filter: " + (i+1) + " times.");
    drawMatrix(matrix, colorhashmap);
  }
  frameRate(24); //only useful for the colorshifting-feature
  saveImage(); //export final fingerprint
}

void draw() {
  //background(20); //uncomment for colorshifting
  colorshift+=1;
  //drawMatrix(matrix, colorhashmap); //uncomment for colorshifting
}

//Draws the matrix
void drawMatrix(String[][] a, HashMap<String, int[]> colormap) {
  int x = a[0].length;
  int y = a[0].length;
  println("Points to draw: " + x + "x" + y + ": " + (x*y));
  float padding = 0f;
  float xsize = (float(width)/x)-padding;
  float ysize = (float(height)/y)-padding;
  println("Pixel-Height: " + ysize + " Pixel-Width: "+xsize);
  noStroke();
  for (int i = 0; i<x; i++) {
    for (int k = 0; k<y; k++) {
      int[] colorattr=colormap.get(a[i][k]);
      if (colorattr!=null && colorattr[1]!=0) {
        fill(color((colorattr[0]+colorshift)%255, 255, colorattr[1]));
        rect((float(width)/x)*i, (float(height)/y)*k, xsize, ysize);
      }
    }
  }
  println("Drawing complete.");
  println("------------");
}

void applyBlur(int a) {
  filter(BLUR, a);
}
void saveImage() {
  save("output.png");
}

//generates colors for all words; colorshift is applied when drawing
HashMap<String, int[]> genHashmap(String[] lyrics) {
  HashMap<String, int[]> output = new HashMap<String, int[]>();
  println("------------");
  println("Before reduction: "+lyrics.length);
  //This is needed atm since the amount of unique words determines the color range.
  lyrics = uniqueLyrics(lyrics);
  println("After reduction: " + lyrics.length);
  println("------------");

  float colorstep = 255f/float(lyrics.length);
  for (int i = 0; i<lyrics.length; i++) {
    int colour = int(colorstep*i);
    if (output.get(lyrics[i])==null) {
      int brightness=255; //Brightness is fixed atm but could be used.
      int[] colorattr = {colour, brightness};
      output.put(lyrics[i], colorattr);
      println("Word: " + lyrics[i] + ", Color: " + colour);
    }
  }
  println("------------");

  return output;
}

//makes sure lyrics only contains each word once
//TODO: replace with hashmap
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

  //Conversion to String[]
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
      }
    }
  }

  //uncomment to remove single pixels
  //output = removeSingles(output);
  return output;
}

//this is a filter to remove single pixels; clears up image
String[][] removeSingles(String[][] input) {
  for (int i = 0; i<input.length-1; i++) {
    for (int j = 0; j<input[0].length-1; j++) {
      if (input[i][j]!=null) { //current pixel is colored
        if (input[i+1][j+1]==null) { //pixel bottom right is not filled.
          if (i>0&&j>0&&input[i-1][j-1]==null) { //pixel top left is not filled.
            input[i][j] = null;
          } else if (i==0 || j==0) {
            input[i][j] = null;
          }
        }
      }
    }
  }
  return input;
}


//I dont currently know why but this removes lyrics such as:
//"La La"
String[] removeDoubleLyrics(String[] lyrics) {
  ArrayList<String> list = new ArrayList<String>();
  for (int i = 0; i<lyrics.length-1; i++) {
    if (!lyrics[i].equals(lyrics[i+1])) {
      list.add(lyrics[i]);
    }
  }
  return list.toArray(new String[0]);
}

//This removes weird spaces, makes text lowercase and if wanted uses cleartext
String[] words(String[] input, Boolean mode) {
  String output = "";
  for (int i = 0; i<input.length; i++) {
    String between = trim(input[i]);
    output=output + between + " ";
  }
  output = trim(output).toLowerCase();

  if (mode) {
    output = cleartext(output);
  }
  
  println("---processed lyrics---");
  println(output);

  String[] outputa = split(output, " ");
  for (int i = 0; i<outputa.length; i++) {
    outputa[i]=trim(outputa[i]);
  }
  return outputa;
}

//Replaces german and french chars; removes anything that is not an alphabetic character
String cleartext(String textv) {
  textv=replaceauo(textv);
  for (int i=0; i<textv.length(); i++) {
    if (!((int(textv.charAt(i))<123 && int(textv.charAt(i))>96)|| textv.charAt(i)==32) ) {
      textv = textv.substring(0, i) + textv.substring(i+1, textv.length());
      i--;
    }
  }
  return textv;
}

//Replaces german and french chars
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
      if (j!=array[i].length-1) {
        output=output+array[i][j]+"|";
      } else {
        output=output+array[i][j];
      }
    }
    println(output);
  }
}
void save2dtxt(String[][] array) {
  String[] outputArray = new String[array[0].length];
  for (int i = 0; i<array[0].length; i++) {
    String output = "";
    for (int j = 0; j<array[i].length; j++) {
      if (j!=array[i].length-1) {
        output=output+array[i][j]+"|";
      } else {
        output=output+array[i][j];
      }
    }
    outputArray[i]=output;
  }
  saveStrings("2darray.txt", outputArray);
}
