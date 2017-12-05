import SimpleOpenNI.*; 

SimpleOpenNI  context; 
PImage img;

//on choisis 2 distance
//celle ou se termine le premier plan
float minZ = 1200;
//celle ou commence l'arriere plan
float maxZ = 1700;

void setup() {
  size(640, 480); 

  //initialize context variable
  context = new SimpleOpenNI(this);

  //asks OpenNI to initialize and start receiving depth sensor's data
  context.enableDepth(); 

  //asks OpenNI to initialize and start receiving User data
  context.enableUser(); 

  //enable mirroring - flips the sensor's data horizontally
  context.setMirror(true); 

  img=createImage(640, 480, RGB);
  img.loadPixels();
}

void draw() {
  //clears the screen with the black color, this is usually a good idea 
  //to avoid color artefacts from previous draw iterations
  background(255);

  //asks kinect to send new data
  context.update();

  //retrieves depth image
  PImage depthImage=context.depthImage();
  depthImage.loadPixels();

  //get user pixels - array of the same size as depthImage.pixels, that gives information about the users in the depth image:
  // if upix[i]=0, there is no user at that pixel position
  // if upix[i] > 0, upix[i] indicates which userid is at that position
  int[] upix=context.userMap();

  //colorize users
  for (int i=0; i < upix.length; i++) {
    if (upix[i] > 0) {
      //there is a user on that position
      //NOTE: if you need to distinguish between users, check the value of the upix[i]
      img.pixels[i]=color(0, 0, 255);
    } else {
      //add depth data to the image
      img.pixels[i]=depthImage.pixels[i];
    }
  }
  img.updatePixels();

  //draws the depth map data as an image to the screen 
  //at position 0(left),0(top) corner
  image(img, 0, 0);

  //draw significant points of users

  //get array of IDs of all users present 
  int[] users=context.getUsers();

  ellipseMode(CENTER);

  //iterate through users
  for (int i=0; i < users.length; i++) {
    int uid=users[i];

    //draw center of mass of the user (simple mean across position of all user pixels that corresponds to the given user)
    PVector realCoM=new PVector();

    //get the CoM in realworld (3D) coordinates
    context.getCoM(uid, realCoM);
    PVector projCoM=new PVector();

    //convert realworld coordinates to projective (those that we can use to draw to our canvas)
    context.convertRealWorldToProjective(realCoM, projCoM);
    fill(255, 0, 0);
    ellipse(projCoM.x, projCoM.y, 10, 10);


    // CONDITION - c'est ici que l'on décide de ce qui se passe aux distances choisie plus haut
    if (projCoM.z < minZ) {//if the user is within a certain range
      fill(255, 0, 0);
      ellipse(projCoM.x, projCoM.y, 50, 50);
    }
    if (projCoM.z > minZ && projCoM.z < maxZ) {//if the user is within a certain range
      fill(0, 255, 0);
      ellipse(projCoM.x, projCoM.y, 50, 50);
    }
    if (projCoM.z > maxZ) {//if the user is within a certain range
      fill(0, 0, 255);
      ellipse(projCoM.x, projCoM.y, 50, 50);
    }



    
  }
}

//is called everytime a new user appears
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  //asks OpenNI to start tracking a skeleton data for this user 
  //NOTE: you cannot request more than 2 skeletons at the same time due to the perfomance limitation
  //      so some user logic is necessary (e.g. only the closest user will have a skeleton)
  curContext.startTrackingSkeleton(userId);
}

//is called everytime a user disappears
void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

