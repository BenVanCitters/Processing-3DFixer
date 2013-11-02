//
//
//Be sure to insall gifAnimation library from:
//   http://www.extrapixel.ch/processing/gifAnimation/

//
//controls:
//     'q':shift up
//     'a':shift down
//     'l':shift right
//     'k':shift left
//     '1':fast display mode
//     '2':slow display mode
//     'e':export an animated gif
//     
// from Create 3D photographs with Processing, 
// http://answers.oreilly.com/topic/1463-create-3d-photographs-with-processing/
// by odewahn1
//
// support for JPL files by Benjamin Van Citters (march-2012)
// these values will be the resolution that final gif 
//will be output in.
//typical images from the evo 3d are 3840x1080
//so each frame is 1920x1080

private static final int WIDTH = 1920/2;
private static final int HEIGHT = 1080/2;

// note that this sketch is only guaranteed to work on jpl/jpg files.
// processing assumes the files are in the same folder as as this .pde file
private static final String JPS_FILEPATH = "IMAG3034.jps";

//////////////////////
//code
//////////////
import gifAnimation.*;
import java.nio.channels.FileChannel;
PGraphics both; 
PGraphics lf; 
PGraphics rt;
String filepaths[];
String lastPath;
int pathIndex = 0;
int rx = 0;  // Horizontal offset for the right image
int ry = 0;  // Vertical offest for the right image
int pause = 100;  //Number of MS to pause b/t left and right images

int rflag = -1;  // toggle that controls which to display

//Set up drawing area
void setup() {
  //typical images from the evo 3d are 3840x1080
  //so each frame is 1920x1080
     File dir = new File(sketchPath("")+"/data/");  
     filepaths = dir.list(new JPSFileFilter());
    println("found these jps files:\n" +  filepaths);
  loadJpl(JPS_FILEPATH);
//  size(lf.width, lf.height);
  size(WIDTH,HEIGHT);
}

void loadJpl(String path)
{
  //this string is sset here so we can properly name any files we export
  lastPath= path;
  path = "/data/" + path;
  println("loading: "  + sketchPath(path));
//  path = path;
  File tmpJpl = new File(sketchPath(path));
  String newfilePath = tmpJpl.getAbsolutePath();
  newfilePath = newfilePath.substring(0, newfilePath.indexOf('.')) + "_tmp.jpg";
  //println("newfilePath: " + newfilePath);
  File tmpJpg = new File(newfilePath);

  try{
    copyFile(tmpJpl,tmpJpg);
  }
  catch(Exception e){
    println(e); 
    tmpJpg.delete();
    //println("temporary file removed."); 
    exit();
    return;
  };
  PImage both = loadImage(newfilePath);//JPG_FILEPATH);
  lf = createGraphics(both.width/2,both.height,P2D);
  rt = createGraphics(both.width/2,both.height,P2D);

  lf.image(both,0,0);
  //shift over and blt to crop off the left
  rt.image(both,-both.width/2.0,0); 
  
  tmpJpg.delete();
  //println("temporary file removed."); 

}

void exportGif() {

  // Set up the gif
  SimpleDateFormat dtFomat = new SimpleDateFormat("yyyyMMddHHmmssZ");
  String fileName = lastPath + "_" + dtFomat.format(new Date()) + ".gif";
  println("exporting... " + fileName);
  GifMaker gifExport = new GifMaker(this, fileName,256);
  //gifExport.setSize(width-abs(rx), height-abs(ry));  //Sets a clip region
  gifExport.setSize(width, height);  //Sets a clip region
  gifExport.setRepeat(0);  //Make this repeat infinitely
  gifExport.setDelay(pause);  //Set the pause rate to 75ms b/t images
  // Draw the right image
  float rtRect[] = new float[]{0,0};
  float lfRect[] = new float[]{0,0};
  getOffsets(rtRect,lfRect);
  image(rt,rtRect[0],rtRect[1],width+abs(rx),height+abs(ry));//  image(rt,rx,ry,width,height);
  gifExport.addFrame();
  //Draw the left frame
  image(lf, lfRect[0],lfRect[1],width+abs(rx),height+abs(ry)); //image(lf,-max(0,rx),-max(0,ry),width,height);
  gifExport.addFrame();
//  println("rt: {" + rx+", " +ry+", " +width+", " +height+"}");
//  println("lf: {" + -max(0,rx)+", " + -max(0,ry)+ ", " + width + ", " + height);
  
  //Save the file
  gifExport.finish();

}
void getOffsets(float[] rtRect,float[] lfRect)
{
  rtRect[0] = (rx > 0) ? 0 : rx;
  rtRect[1] = (ry > 0) ? 0 : ry;
  
  lfRect[0] = (rx < 0) ? 0 : -rx;
  lfRect[1] = (ry < 0) ? 0 : -ry;  
}
//Simple control scheme  
void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      pathIndex = (pathIndex+1)%filepaths.length;
      loadJpl(filepaths[pathIndex]);        
  }
    if (keyCode == LEFT) {
      pathIndex = (--pathIndex >= 0)? pathIndex: filepaths.length-1;
      println("loading: "  + filepaths[pathIndex]);
      loadJpl(filepaths[pathIndex]);
    }
  }
  else
  {
    switch (key) {
       case 'q':  //shift up
          ry -= 2;
          break;
       case 'a':  //shift down
          ry += 2;
          break;
       case 'l':
          rx += 2;  //shift right
          break;
       case 'k':
          rx -= 2;  //shift left
          break;
       case '1':
          pause = max(0,pause-25); //fast display mode
          break;
       case '2':   //slow display mode
          pause += 25;
          break;
       case 'e':  //export an animated gif
          exportGif();
          break;    
    }
  }
}

void draw() {
  delay(pause);
  //println(rx + " , " + ry);
  if (rflag == -1) {
     image(rt,rx,ry,width,height);  //Draw the right image at the current offest position
  } else {
     image (lf,0,0,width,height);  //Draw the left image
  }
  rflag *= -1;  // toggle the image
}  

// from: http://stackoverflow.com/questions/106770/standard-concise-way-to-copy-a-file-in-java
// retrieved march 10th 2012
// author unknown :(
void copyFile(File sourceFile, File destFile) throws IOException {
    if(!destFile.exists()) {
        destFile.createNewFile();
    }

    FileChannel source = null;
    FileChannel destination = null;

    try {
        source = new FileInputStream(sourceFile).getChannel();
        destination = new FileOutputStream(destFile).getChannel();
        destination.transferFrom(source, 0, source.size());
    }
    finally {
        if(source != null) {
            source.close();
        }
        if(destination != null) {
            destination.close();
        }
    }
}


void stop(){
 super.stop();
}

class JPSFileFilter implements FilenameFilter{
  public boolean accept(File dir,String name){
    return name.endsWith(".jps");
  }
  
}
