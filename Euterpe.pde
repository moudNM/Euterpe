//Name:Nur Muhammad Bin Khameed
//Student ID:160269044
//Processing 3.2.1.

/*I made a song recommender that recommends
 *an artist to you based on the artists that
 *you select.
 *
 *This program uses the ControlP5 library for GUI
 *It also uses javafx for the youtube player,
 *which is a runnable jar file (standalone)
 *
 *Opening an artist profile should take approximately 2 seconds
 *Discover function should take approximately 13-15 secs
 *Any delay may be due to slow access to lastfm APIs
 *If delay persists, restart the program
 *There may even be connection error(socket timeout) to the APIs
 */


import controlP5.*;
import java.util.HashSet;
import java.util.Map;
import java.net.URLEncoder;
import java.net.*;
import java.io.*;
import static javax.swing.JOptionPane.*;

ControlP5[] c;
boolean[] b;
Canvas intro, loading;

PFont ProfileNameFont, ProfileNameFont2, ProfileGenreFont, ProfileGenreFont2;
PFont textFieldFont;
PFont artfontS, artfontSS;
PFont DisplayFontM, DisplayFontL;

float timer;
Boolean update = true;
int state, Mstate;

int theme;
String[] themeNames;
CColor[] TFcolors;
CColor[] TAcolors;
CColor[] SLcolors;
CColor[] SLcolors2;
int[] Backg;


//two(2)
String username; //holds name input
boolean invalid2;

//three(3)
boolean invalid3;

//four(4)
ArrayList<Artist> artist;

//five(5)
Artist currentartist;
VidThread[] v;

//six(6)
int sixMsg;

//eight(8)
ArrayList<String> newArtists;
HashMap<String, Integer> tagOverall;
HashMap<String, Integer> topFiveTags;
ArrayList<String> discovername;
discoverThread[] d;

//ten(10)
int tenMsg;

//list(11)
ArrayList<Artist> likes;
ArrayList<Artist> discover;

//settings(12)
ArrayList<String> option;
ArrayList<String> option2;


void setup() {
  size(696, 696);

  createAllFonts();
  initialize();
}



void draw() {

  background(Backg[theme]);
  
  update();

  timer = millis();
//after 2.5 seconds, move on from app logo
  if (state==0 && timer>2500) {
    state = 1;
    update = true;
  }

//after completing discovery, move on to next screen
  if (state == 7 &&b[7]) {
    state = 8;
    discover();
    update = true;
  }
}


//////////////////////////////////////////////////////////Custom classes////////////////////////////////////////////

//Creates logo screens (Euterpe Logo,Loading Screen)
class Screen extends Canvas {
  PImage logo;
  String logoS;

  public Screen(String img) {
    logoS = img;
  }
  public void setup(PGraphics pg) {
    logo = loadImage(logoS);
  }  

  public void update(PApplet p) {
  }

  public void draw(PGraphics pg) {
    // intro logo
    pg.fill(255, 125, 0);
    pg.image(logo, (width-(logo.width))/2, (height-(logo.height))/2);
    b[7] = true;
  }
}

class Artist {
  String name;
  String image;
  String id;
  HashMap<String, Integer> tag;
  ArrayList<Track> track;

  Artist(String n, String im, String id) {
    name = n;
    image = im;
    this.id = id;
  }

  void setImage(String img) {
    image = img;
  }

  void setTag(HashMap<String, Integer> t) {
    tag = t;
  }

  void setTracks(ArrayList<Track> tr) {
    track = tr;
  }

  String getName() {
    return name;
  }

  String getImage() {
    return image;
  }

  HashMap<String, Integer> getTags() {
    return tag;
  }
  ArrayList<Track> getTracks() {
    return track;
  }
}


class Track {
  String name;
  String playcount;
  String url;
  String vidurl;
  Track(String n, String p, String u) {
    name = n;
    playcount = p;
    url = u;
  }

  String getName() {
    return name;
  }

  String getCount() {
    return playcount;
  }

  String getUrl() {
    return url;
  }

  String getVidUrl() {
    return vidurl;
  }

  public void setVidUrl(String vu) {
    vidurl = vu;
  }
}

class miniTag {
  String name;
  int count;

  miniTag(String n, int c) {
    name = n;
    count = c;
  }

  String getName() {
    return name;
  }

  int getCount() {
    return count;
  }
}

class VidThread extends Thread {

  String vu;
  Track t;

  public VidThread(Track t) {
    this.t = t;
  }

  public void run() {
    vu = yt(t.getUrl());
    t.setVidUrl(vu);
  }
}


class discoverThread extends Thread {

  String s;

  public discoverThread(String s) {
    this.s = s;
  }

  public void run() {
    loadDiscover(s);
  }
}






//////////////////////////////////////////////////////////Methods that call the api////////////////////////////////////////////

//uses the api to search for the specified artist
ArrayList <Artist> searchArtists(String ArtName) {
  String query = ArtName;
  try {
    query = URLEncoder.encode(query, "UTF-8");
  }
  catch(Exception e) {
  }

  String url = "http://ws.audioscrobbler.com/2.0/?method=artist.search&artist=" + query + "&api_key=5f89b5026e6206e9b74b93a117a4ef95&format=json&limit=50";
  JSONObject json = loadJSONObject(url);
  int ArtSize = json.getJSONObject("results").getJSONObject("artistmatches").getJSONArray("artist").size();
  JSONArray jsonA = json.getJSONObject("results").getJSONObject("artistmatches").getJSONArray("artist");

  if (ArtSize >6) ArtSize = 6;
  ArrayList <Artist> Art = new ArrayList<Artist>();

  int i = 0;

  while (i<ArtSize) {

    String id = null;
    try {
      id = jsonA.getJSONObject(i).getString("mbid");
    }
    catch(Exception e) {
    }
    String name = jsonA.getJSONObject(i).getString("name");
    String imgurl = jsonA.getJSONObject(i).getJSONArray("image").getJSONObject(2).getString("#text"); 

    Art.add(new Artist(name, imgurl, id));
    i++;
  }

  //for (Artist a : Art) println("Name:"+a.name+ "  Id:" + a.id + "  Imgurl:" + a.image) ;

  return Art;
}

//loads the top tracks for the specified artist
ArrayList <Track> loadTracks(String ArtName) {
  String query = ArtName;
  try {
    query = URLEncoder.encode(query, "UTF-8");
  }
  catch(Exception e) {
  }

  String url = "http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=" + query + "&api_key=5f89b5026e6206e9b74b93a117a4ef95&format=json";
  JSONObject json = loadJSONObject(url);
  int TrackSize = json.getJSONObject("toptracks").getJSONArray("track").size();
  JSONArray jsonA = json.getJSONObject("toptracks").getJSONArray("track");

  if (TrackSize >10) TrackSize = 10;

  ArrayList<Track> ArtTrack = new ArrayList<Track>();
  for (int i=0; i<TrackSize; i++) {

    String name = jsonA.getJSONObject(i).getString("name");
    String vUrl = jsonA.getJSONObject(i).getString("url");
    String playcount = jsonA.getJSONObject(i).getString("playcount");
    Track t = new Track(name, playcount, vUrl);
    ArtTrack.add(t);
  }
  //for (Track t : ArtTrack) println(t.name);
  return ArtTrack;
}



//loads the tags for the specified artist
HashMap<String, Integer> loadGenres(String ArtName) {

  String query = ArtName;
  try {
    query = URLEncoder.encode(query, "UTF-8");
  }
  catch(Exception e) {
  }


  String url = "http://ws.audioscrobbler.com/2.0/?method=artist.gettopTags&artist=" + query + "&api_key=5f89b5026e6206e9b74b93a117a4ef95&format=json";
  JSONObject json = loadJSONObject(url);

  int TagSize = json.getJSONObject("toptags").getJSONArray("tag").size();
  JSONArray jsonA = json.getJSONObject("toptags").getJSONArray("tag");

  if (TagSize>5) TagSize = 5;

  HashMap<String, Integer> ArtTag = new HashMap<String, Integer>();
  for (int i=0; i<TagSize; i++) {

    String name = jsonA.getJSONObject(i).getString("name");
    int count = jsonA.getJSONObject(i).getInt("count");

    ArtTag.put(name, count);
  }

  return ArtTag;
}

//loads the artist info(name,img,id) for the specified artist
Artist GetArtist(String ArtName) {

  String query = ArtName;
  try {
    query = URLEncoder.encode(query, "UTF-8");
  }
  catch(Exception e) {
  }

  String url = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=" + query + "&api_key=5f89b5026e6206e9b74b93a117a4ef95&format=json";
  JSONObject json = loadJSONObject(url);
  String id = null;
  try {
    id = json.getJSONObject("artist").getString("mbid");
  }
  catch(Exception e) {
  }

  String name = json.getJSONObject("artist").getString("name");
  String imgurl = json.getJSONObject("artist").getJSONArray("image").getJSONObject(2).getString("#text");

  Artist Art = new Artist(name, imgurl, id);


  return Art;
}

//loads the artist tracks and genre
Artist loadArtist(Artist Art) {

  String ArtName = Art.getName();

  String query = ArtName;

  Art.setTracks(loadTracks(query));//load tracks
  Art.setTag(loadGenres(query));//load genre

  return Art;
}

////////////////////////////////////Display Methods///////////////////////////////////////

//create all fonts
void createAllFonts() {
  ProfileNameFont = createFont("big_noodle_titling.ttf", 40, true);
  ProfileNameFont2 = createFont("unifont.ttf", 40, true);
  ProfileGenreFont = createFont("big_noodle_titling.ttf", 23, true);
  ProfileGenreFont2 = createFont("unifont.ttf", 23, true);

  textFieldFont = createFont("unifont.ttf", 30, true);

  artfontSS = createFont("unifont.ttf", 18, true);
  artfontS = createFont("unifont.ttf", 20, true);
  DisplayFontM = createFont("big_noodle_titling.ttf", 23, true);
  DisplayFontL = createFont("big_noodle_titling.ttf", 40, true);
}

//create all themes
void createAllThemes() {

  theme = 0;

  themeNames = new String[2]; 
  TAcolors = new CColor[2];
  TFcolors = new CColor[2];
  SLcolors = new CColor[2];
  SLcolors2 = new CColor[2];
  Backg = new int[2];


  //Aerospace theme
  themeNames[0] = "Aerospace";
  TAcolors[0] = new CColor(0, color(#FFFFFF), 0, 0, color(#FF4F00));
  TFcolors[0] = new CColor(color(#FF4F00), color(#BA160C), color(#FF4F00), 0, color(#FFFFFF));  
  SLcolors[0] = new CColor(color(#BA160C), color(#FF4F00), color(#BA160C), 0, color(#FFFFFF));
  SLcolors2[0] = new CColor(color(#A9A9A9), color(#D3D3D3), color(#A9A9A9), 0, color(#FF4F00));
  Backg[0] = 255;

  //Hackerman
  themeNames[1] = "Hackerman";
  TAcolors[1] = new CColor(0, color(#000000), 0, 0, color(#00FF00));
  TFcolors[1] = new CColor(color(#00FF00), color(#49796B), color(#00FF00), 0, color(#000000));  
  SLcolors[1] = new CColor(color(#49796B), color(#00FF00), color(#49796B), 0, color(#000000));
  SLcolors2[1] = new CColor(color(#696969), color(#808080), color(#696969), 0, color(#00FF00));
  Backg[1] = 0;
}

//starts the program
void initialize() {

  createAllThemes();
  clearAllLists();
  createPages();
  likes = new ArrayList<Artist>();
  discover = new ArrayList<Artist>();

  state = 0; //toggle this to test different states
  update = true;
}

//create all the GUI windows
void createPages() {
  b = new boolean[13];
  c = new ControlP5[13];

  for (int i = 0; i<c.length; i++) {
    c[i] = new ControlP5(this);
  }

  for (int i = 0; i<b.length; i++) {
    b[i] = false;
  }

  invalid();
}

void invalid() {
  invalid2 = false;
  invalid3 = false;
}

//hides all windows and reset boolean values
void hideAll() {
  for (int i = 0; i<c.length; i++) {
    c[i].hide();
  }


  for (int i = 0; i<b.length; i++) {
    b[i] = false;
  }
}

//resets all lists
void clearAllLists() {
  tagOverall=new HashMap<String, Integer>();
  topFiveTags=new HashMap<String, Integer>();
  discovername=new ArrayList<String>();
  d=new discoverThread[5];
  v =new VidThread[10];
  likes=new ArrayList<Artist>();
  discover=new ArrayList<Artist>();
}


//updates the state(GUI window)
void update() {  

  if (update) {
    println("State is:" + state);
    update = false;
    switch(state) {

    case 11:
      lists();
      break;

    case 12:
      Settings();
      break;

    case 0: 
      zero();
      break;

    case 1: 
      one();
      break;

    case 2: 
      two();
      break;

    case 3: 
      three();
      break;

    case 4: 
      four();
      break;

    case 5: 
      five();
      break;

    case 6: 
      six();
      break;

    case 7: 
      seven();
      break;

    case 8: 
      eight();
      break;

    case 9: 
      nine();
      break;

    case 10: 
      ten();
      break;
    }
  }
}


//listener for textfields and some buttons
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    if (state == 2) {

      username = theEvent.getStringValue();
      if (username.length() <= 20 && username.length() > 0) {
        state = 3;
        update = true;
      } else {
        invalid2 = true;
        update = true;
      }
    }


    if (state == 3 && b[3]) {
      String songinput = theEvent.getStringValue();
      println("here:"+songinput.length());
      if (songinput.length() != 0) {
        artist = searchArtists(songinput);
        state = 4;
        update = true;
      } else {
        invalid3 = true;
        update = true;
      }
    }
  }

  if (state == 4) {
    if (b[4]) {
      if (theEvent.getController().getName().startsWith("img")) {
        int i = (int) theEvent.getController().getValue();
        println("Opening:" + artist.get(i).name);
        currentartist = artist.get(i);
        currentartist = loadArtist(currentartist);
        state = 5;
        update = true;
      }
    }
  }

  if (state == 5) { 
    if (b[5]) {
      if (theEvent.getController().getName().startsWith("player")) {
        int i = (int) theEvent.getController().getValue();
        String url = currentartist.getTracks().get(i).getVidUrl();
        if (url == null || !url.equals("nil")) launchPlayer(url);
      }
    }
  }

  if (state == 9) { 
    if (b[9]) {
      if (theEvent.getController().getName().startsWith("player")) {
        int i = (int) theEvent.getController().getValue();
        String url = currentartist.getTracks().get(i).getVidUrl();
        if (url == null || !url.equals("nil")) launchPlayer(url);
      }
    }
  }


  if (state == 12) {
    if (b[12]) {
      if (theEvent.getController().getName().startsWith("next")) {
        int i = (int) theEvent.getController().getValue();

        if (i == 0) {
          if (theme<(themeNames.length-1)) {
          theme++;
          }else if(theme == (themeNames.length-1)){
          theme = 0;
          }
          update = true;
        }

      }
    }
  }
}


////////////////////////////////////////Draws the GUI windows/pages/////////////////////

//Intro screen
void zero() { 
  intro = new Screen("Logos/EuterpeLogo.png");
  intro.pre();
  c[0].addCanvas(intro);
  c[0].show();
}

//Welcome message
void one() { 

  clearAllLists();
  hideAll();

  background(0);
  Textarea welcome, welcome2;
  welcome = c[1].addTextarea("welcome")
    .setPosition(width/5, height/8)
    .setSize(300, 100)
    .hideScrollbar() 
    .setLineHeight(32)
    .setFont(DisplayFontL)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Welcome to Euterpe");
  ;

  welcome2 = c[1].addTextarea("welcome2")
    .setPosition(width/5, 75+(height/8))
    .setSize(width, height/4)
    .hideScrollbar() 
    .setLineHeight(32)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Euterpe is a song artist recommender, created for a UOL" +"\n" +
    "coursework project. It is named after the Greek Goddess" +"\n" +
    "and muse of music/lyrical poetry, Euterpe. Euterpe is" +"\n" +
    "powered by the Last.fm database and a very simple " +"\n" +
    "recommender algorithm of my own design. So go ahead, " +"\n" +
    "give it a try. Who knows, maybe you'll find some new bands " +"\n" +
    "that you just might like.")

    ;


  c[1].addButton("one1")
    .setValue(0)
    .setPosition(175, 350)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/1b1.png"));
  ;

  c[1].addButton("one2")
    .setValue(0)
    .setPosition(350, 350)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/1b2.png"));
  ;

  c[1].show();
  b[1] = true;
}

public void one1() {
  if (b[1]) {
    state = 2;
    update = true;
  }
}

public void one2() {
  if (b[1]) {
    exit();
  }
}

//User name input
void two() { 
  hideAll();

  c[2] = new ControlP5(this);

  c[2].addTextarea("NameInput1")
    .setPosition(width/4, height/4)
    .setSize(width/2, height/12)
    .setLineHeight(32)
    .setFont(DisplayFontL)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Please enter your name.")
    .hideScrollbar()
    ;

  c[2].addTextfield("NameInput2")
    .setPosition(3*(width/8)-25, height/3)
    .setSize(width/4, 40)
    .setFocus(true)
    .setFont(textFieldFont)
    .setColor(TFcolors[theme])
    .setCaptionLabel ("")
    ;

  if (invalid2) {
    c[2].addTextarea("InvalidInput")
      .setPosition(width/4, 100 + (height/4))
      .setSize(width/2, height/6)
      .setLineHeight(32)
      .setColor(color(255, 0, 0))
      .setFont(DisplayFontM)
      .setText("Invalid Input.\n"
      + "Name has to be at least one character long \n" 
      + "and at most 20 characters."
      )
      .hideScrollbar()
      ;
  }



  c[2].show();
}

//search for artist
void three() {
  hideAll();

  c[3] = new ControlP5(this);

  artist = null;
  Textarea start3a, start3b;
  start3a =  c[3].addTextarea("start3a")
    .setPosition(width/4, 5*(height/24))
    .setSize(width/2, height/8)
    .setLineHeight(32)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setFont(DisplayFontL)
    .setText("Alright, "  + username + ".")
    .hideScrollbar()
    ;

  start3b = c[3].addTextarea("start3b")
    .setPosition(width/4, 8*(height/24))
    .setSize(width/2, height/8)
    .setLineHeight(32)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setFont(DisplayFontL)
    .setText("Please tell me the name of an artist that you like.")
    .hideScrollbar()
    ;

  Textfield tf;
  tf = c[3].addTextfield("txtf3")
    .setPosition(3*(width/8)-50, 12*(height/24))
    .setSize(200, 40)
    .setFocus(true)
    .setFont(textFieldFont)
    .setColor(TFcolors[theme])
    .setCaptionLabel ("")
    ;


  if (invalid3) {
    c[3].addTextarea("InvalidInput")
      .setPosition(width/4, 50 + (height/2))
      .setSize(width/2, height/6)
      .setLineHeight(32)
      .setColor(color(255, 0, 0))
      .setFont(DisplayFontM)
      .setText("Invalid Input.\n"
      + "Name cannot be blank."
      )
      .hideScrollbar()
      ;
  }


  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[3].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[3].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[3].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  b[3] = true;
  c[3].show();
}

//displays searched artist(s)
void four() {//takes approx 5-7secs
  hideAll();
  c[4] = new ControlP5(this);


  for (int i =0; i<artist.size(); i++) {
    c[4].remove("img" + i);
    c[4].remove("artist" + i);
  }


  int imgW = 174;
  int side = 35;
  int gap =( width - (2*side) -(3*imgW))/2;
  int textH = 50;



  for (int i =0; i<artist.size(); i++) {

    int posX = side+((i%3)*imgW)+((i%3)*gap);

    int posY = 100;
    if (i>=3) posY +=(imgW + textH);
    if (loadImage(artist.get(i).image) == null) {
      Artist art = new Artist(artist.get(i).name, "Logos/unknown.png", artist.get(i).id);
      artist.set(i, art);
    }



    c[4].addButton("img"+ i)
      .setValue(i)
      .setPosition(posX, posY)
      .setSize(imgW, imgW)
      .setImage(loadImage(artist.get(i).image))      
      ;


    c[4].addTextarea("artist" + i )
      .setPosition(posX, posY+imgW)
      .setSize(174, textH)
      .setLineHeight(32)
      .setColorValue(TAcolors[theme].getValueLabel())
      .setFont(artfontS)
      .setText(artist.get(i).name)
      .hideScrollbar() 
      ;
  }


  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[4].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[4].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[4].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;


  c[4].addButton("back4")
    .setPosition(0, height-40)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/back4.png"));
  ;

  b[4] = true;
  c[4].show();
}  

public void back4() {
  if (b[4]) {
    state = 3;
    update = true;
  }
}


//draws the selected artist profile
void five() {
  hideAll();

  c[5] = new ControlP5(this);
  c[5].setFont(artfontSS);


  int imgW = 174;
  int side = 35;
  int space = width - (3*side)-imgW;
  int textH = 50;


  if (loadImage(currentartist.getImage()) == null) {
    currentartist.setImage("Logos/unknown.png");
  }

  Button artimage;
  Textarea artname;
  artimage = c[5].addButton("artimage")
    .setPosition(side, 25)
    .setSize(imgW, imgW)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setImage(loadImage(currentartist.getImage()))
    ;



  //restrict displayed artist name
  String displayName = currentartist.getName();
  if (displayName.length()>28) {
    displayName = displayName.substring(0, 26);
    displayName+="...";
  }

  PFont artnamefont = ProfileNameFont;
  try {
    String testname = URLEncoder.encode(displayName, "UTF-8");
    if (testname.contains("%")) {
      artnamefont = ProfileNameFont2;
    }
  }
  catch(Exception e) {
  }
  artname = c[5].addTextarea("artname")
    .setPosition((2*side) + imgW, 25+(imgW/4))
    .setSize(space, 50)
    .setFont(artnamefont)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText(displayName)
    .hideScrollbar()
    ;

  ////genres   
  Textarea genres;
  String genre = " · ";
  for (Map.Entry me : currentartist.getTags().entrySet()) {
    genre += (me.getKey());
    genre += " · ";
  }

  genres = c[5].addTextarea("Genres")
    .setPosition((3*side/2) + imgW, 60+ 25+(imgW/4))
    .setSize(space, 100)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setFont(ProfileGenreFont)
    .setText(genre)
    .hideScrollbar() 
    ;




  //list of songs
  Textarea topsongs;
  ScrollableList topsongs2;

  ArrayList artsong = new ArrayList<String>();
  for (Track t : currentartist.getTracks()) {
    String songname = t.getName();
    if (songname.length()>50) {
      songname = songname.substring(0, 48);
      songname+="...";
    }
    artsong.add(songname);
  }




  topsongs = c[5].addTextarea("Top Songs")
    .setPosition(side, 30+imgW)
    .setSize(300, 40)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Top Songs")
    .hideScrollbar() 
    ;

  topsongs2 = c[5].addScrollableList("Top Songs2")
    .setPosition(side, 65+imgW)
    .setSize(width-(2*side)-135, 385)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(artsong)
    .setColor(SLcolors2[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;


  //player

  if (currentartist.getTracks().get(0).getVidUrl() == null) {

    int t1 = millis();

    v = new VidThread[10];
    for (int i =0; i<currentartist.getTracks().size(); i++) {
      v[i] = new VidThread(currentartist.getTracks().get(i));
      v[i].start();
    }


    for (VidThread v2 : v) {
      try {
        v2.join();
      }
      catch(Exception e) {
      }
    }

    int t2 = millis();
    println("Time for songload:" + (t2-t1));
  }



  for (int i = 0; i<currentartist.getTracks().size(); i++) {
    String img = "Buttons/" + theme + "/play1.png";
    if (currentartist.getTracks().get(i).getVidUrl().equals("nil")) img = "Buttons/" + theme + "/play0.png";
    c[5].addButton("player"+i)
      .setValue(i)
      .setPosition(width-side-135, 65+imgW+(i*35))
      .setSize(35, 35)
      .setImage(loadImage(img))
      ;
  }

  //playcount
  Textarea playcount;
  ScrollableList playcount2;


  ArrayList songcount = new ArrayList<String>();
  for (Track t : currentartist.getTracks()) {
    songcount.add(t.getCount());
  }



  playcount = c[5].addTextarea("Playcount")
    .setPosition(width-side-100, 30+imgW)
    .setSize(100, 40)
    .setColor(color(#FF4F00))
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Playcount")
    .hideScrollbar() 
    ;

  playcount2 = c[5].addScrollableList("Playcount2")
    .setPosition(width-side-100, 65+imgW)
    .setSize(100, 385)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(songcount)
    .setColor(SLcolors2[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;

  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[5].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[5].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[5].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  c[5].addButton("add5")
    .setPosition((width-150)/2, height-40-40)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/add5.png"))
    ;

  c[5].addButton("back5")
    .setPosition(0, height-40)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/back5.png"))
    ;

  b[5] = true;
  c[5].show();
}


void add5() {
  if (b[5]) {
    boolean b = true;
    sixMsg = 0;
    for (Artist a : likes) {
      if (currentartist.name.equals(a.name) && currentartist.image.equals(a.image) && currentartist.id.equals(a.id)) {
        b = false;
        sixMsg = 1;
      }
    }

    for (Artist a : discover) {
      if (currentartist.name.equals(a.name) && currentartist.image.equals(a.image) && currentartist.id.equals(a.id)) {
        b = false;
        sixMsg = 1;
      }
    }
    if (b) {
      likes.add(currentartist);
    }
    state = 6;
    update = true;
  }
}

void back5() {
  if (b[5]) {
    state = 4;
    update = true;
  }
}


//display added/not message
void six() {
  hideAll();

  c[6] = new ControlP5(this);

  int side = 35;
  String SixMessage = "";
  switch(sixMsg) {

  case 0:
    SixMessage = "Artist Added!" + "\n" +
      "Please add more artists or try the discover button!";
    break;

  case 1:
    SixMessage = "Sorry, but the artist is already on your list." + "\n" +
      "Please add more artists or try the discover button!";
    break;

  case 2:
    SixMessage = "";
    break;
  }

  c[6].addTextarea("SixMessage")
    .setPosition(side, 75+(height/8))
    .setSize(width-(side*2), height/4)
    .setColor(color(255, 125, 0))
    .setFont(DisplayFontL)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText(SixMessage)
    .hideScrollbar() 
    ;



  c[6].addButton("add6")
    .setPosition(0, 610)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/add6.png"))
    ;

  c[6].addButton("discover6")
    .setPosition(0, 658)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/discover6.png"))
    ;

  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[6].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[6].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[6].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  b[6] = true;
  c[6].show();
}

void add6() {
  if (b[6]) {
    state = 3;
    update= true;
  }
}

void discover6() {
  if (b[6]) {
    state = 7;
    update= true;
  }
}

//discovery load screen
void seven() {
  hideAll();
  background(255);
  loading = new Screen("Logos/" + theme + "/LoadingLogo.png");
  c[7] = new ControlP5(this);
  c[7].addCanvas(loading);
  c[7].show();
}


//Display all recommended artists
void eight() {
  hideAll();

  c[8] = new ControlP5(this);
  c[8].setFont(artfontSS);

  int side = 35;

  //list of artist matches
  Textarea matches;
  ScrollableList matches2;

  newArtists = new ArrayList<String>();
  for (String s : discovername) {
    newArtists.add(s);
  }

  ArrayList<Artist> combined = new ArrayList<Artist>();
  combined.addAll(likes);
  combined.addAll(discover);

  ArrayList newArtists2 = new ArrayList<String>();

  //remove artists from likes list
  for (String s : newArtists) { 
    boolean same = false;

    for (Artist a : combined) {
      if (s.equals(a.name)) {
        same = true;
        break;
      }
    }
    if (!same) {
      newArtists2.add(s);
    }
  }
  //remove duplicates
  HashSet<String> newArtists3 = new HashSet<String>(newArtists2);
  newArtists = new ArrayList<String>();
  newArtists.addAll(newArtists3);


  ArrayList<String> newArtistsnames = new ArrayList<String>();
  newArtistsnames = newArtists;

  for (int i = 0; i<newArtistsnames.size(); i++) {
    if (newArtistsnames.get(i).length()>28) {
      String displayName = newArtistsnames.get(i).substring(0, 25);
      displayName+="...";
      newArtistsnames.set(i, displayName);
    }
  }




  matches = c[8].addTextarea("RecommendedArtists")
    .setPosition(side, 100)
    .setSize(300, 40)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Recommended Artists")
    .hideScrollbar() 
    ;

  matches2 = c[8].addScrollableList("RecommendedArtists2")
    .setPosition(side, 135)
    .setSize((width/2)-side, 385)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(newArtistsnames)
    .setColor(SLcolors2[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;


  c[8].addTextarea("Tip")
    .setPosition(side + ((width-side)/2), 135)
    .setSize((width/2)-side, 400)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Select on an artist to look at their profile."+"\n" +"\n"
    +"If there is nothing you like, press the return button and add more artists to the mix. This will help in improving recommended artist matches for you.")
    .hideScrollbar() 
    ;

  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[8].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[8].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[8].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  c[8].addButton("back8")
    .setPosition(0, 658)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/back8.png"))
    ;

  b[8] = true;
  c[8].show();
}

void back8() {
  state = 3;
  update = true;
}

//methods for selecting from eight list
void RecommendedArtists2(int n) {
  if (b[8]) {
    /* request the selected item based on index n */
    String name = newArtists.get(n);
    println("opening " + name);
    currentartist = GetArtist(name);
    currentartist = loadArtist(currentartist);
    state = 9;
    update = true;
  }
}


//Display artist profile
void nine() {

  hideAll();

  c[9] = new ControlP5(this);
  c[9].setFont(artfontSS);


  int imgW = 174;
  int side = 35;
  int space = width - (3*side)-imgW;
  int textH = 50;

  //add

  if (loadImage(currentartist.getImage()) == null) {
    currentartist.setImage("Logos/unknown.png");
  }

  Button artimage;
  Textarea artname;
  artimage = c[9].addButton("artimage")
    .setPosition(side, 25)
    .setSize(imgW, imgW)
    .setImage(loadImage(currentartist.getImage()))
    ;



  //restrict displayed artist name
  String displayName = currentartist.getName();
  if (displayName.length()>28) {
    displayName = displayName.substring(0, 26);
    displayName+="...";
  }


  PFont artnamefont = ProfileNameFont;
  try {
    String testname = URLEncoder.encode(displayName, "UTF-8");
    if (testname.contains("%")) {
      artnamefont = ProfileNameFont2;
    }
  }
  catch(Exception e) {
  }

  artname = c[9].addTextarea("artname")
    .setPosition((2*side) + imgW, 25+(imgW/4))
    .setSize(space, 50)
    .setFont(artnamefont)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText(displayName)
    .hideScrollbar() 
    ;

  ////genres   
  Textarea genres;
  String genre = " · ";
  for (Map.Entry me : currentartist.getTags().entrySet()) {
    genre += (me.getKey());
    genre += " · ";
  }

  genres = c[9].addTextarea("Genres")
    .setPosition((3*side/2) + imgW, 50+25+(imgW/4))
    .setSize(space, 100)
    .setFont(ProfileGenreFont)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText(genre)
    .hideScrollbar() 
    ;




  //list of songs
  Textarea topsongs;
  ScrollableList topsongs2;

  ArrayList artsong = new ArrayList<String>();
  for (Track t : currentartist.getTracks()) {
    String songname = t.getName();
    if (songname.length()>50) {
      songname = songname.substring(0, 48);
      songname+="...";
    }
    artsong.add(songname);
  }

  topsongs = c[9].addTextarea("Top Songs")
    .setPosition(side, 30+imgW)
    .setSize(300, 40)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Top Songs")
    .hideScrollbar() 
    ;

  topsongs2 = c[9].addScrollableList("Top Songs2")
    .setPosition(side, 65+imgW)
    .setSize(width-(2*side)-135, 385)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(artsong)
    .setColor(SLcolors2[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;

  //load songs
  if (currentartist.getTracks().get(0).getVidUrl() == null) {
    //player
    int t1 = millis();

    v = new VidThread[10];
    for (int i =0; i<currentartist.getTracks().size(); i++) {
      v[i] = new VidThread(currentartist.getTracks().get(i));
      v[i].start();
    }


    for (VidThread v2 : v) {
      try {
        v2.join();
      }
      catch(Exception e) {
      }
    }

    int t2 = millis();
    println("Time for songload:" + (t2-t1));
  }

  for (int i = 0; i<currentartist.getTracks().size(); i++) {
    String img = "Buttons/" + theme + "/play1.png";
    if (currentartist.getTracks().get(i).getVidUrl().equals("nil")) img = "Buttons/" + theme + "/play0.png";
    c[9].addButton("player"+i)
      .setValue(i)
      .setPosition(width-side-135, 65+imgW+(i*35))
      .setSize(100, 35)
      .setImage(loadImage(img))
      ;
  }

  //playcount
  Textarea playcount;
  ScrollableList playcount2;


  ArrayList songcount = new ArrayList<String>();
  for (Track t : currentartist.getTracks()) {
    songcount.add(t.getCount());
  }



  playcount =c[9].addTextarea("Playcount")
    .setPosition(width-side-100, 30+imgW)
    .setSize(100, 40)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Playcount")
    .hideScrollbar() 
    ;

  playcount2 = c[9].addScrollableList("Playcount2")
    .setPosition(width-side-100, 65+imgW)
    .setSize(100, 385)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(songcount)
    .setColor(SLcolors2[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;

  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[9].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[9].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[9].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  c[9].addButton("add9")
    .setPosition((width-150)/2, height-40-40)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/add9.png"))
    ;

  c[9].addButton("back9")
    .setPosition(0, height-40)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/back9.png"))
    ;

  b[9] = true;
  c[9].show();
}

void add9() {
  if (b[9]) {
    boolean b = true;
    tenMsg = 0;
    for (Artist a : discover) {
      if (currentartist.name.equals(a.name) && currentartist.image.equals(a.image) && currentartist.id.equals(a.id)) {
        b = false;
        tenMsg = 1;
      }
    }
    if (b) {
      discover.add(currentartist);
    }
    state = 10;
    update = true;
  }
}

void back9() {
  if (b[9]) {
    state = 8;
    update = true;
  }
}

//artist added/not message
void ten() {

  hideAll();

  c[10] = new ControlP5(this);

  int side = 35;
  String TenMessage = "";
  switch(tenMsg) {

  case 0:
    TenMessage = "Artist Added!" + "\n" +
      "Please add more artists or try the discover button!";
    break;

  case 1:
    TenMessage = "Sorry, but the artist is already on your list." + "\n" +
      "Please add more artists or try the discover button!";
    break;

  case 2:
    TenMessage = "";
    break;
  }

  c[10].addTextarea("TenMessage")
    .setPosition(side, 75+(height/8))
    .setSize(width-(side*2), height/4)
    .setFont(DisplayFontL)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText(TenMessage)
    .hideScrollbar() 
    ;


  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[10].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search1.png"))
    ;

  c[10].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[10].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  c[10].addButton("add10")
    .setPosition(0, 610)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/add6.png"))
    ;

  c[10].addButton("discover10")
    .setPosition(0, 658)
    .setSize(150, 40)
    .setImage(loadImage("Buttons/" + theme + "/discover6.png"))
    ;


  b[10] = true;
  c[10].show();
}

void add10() {
  if (b[10]) {
    state = 3;
    update= true;
  }
}

void discover10() {
  if (b[10]) {
    state = 7;
    update= true;
  }
}


/////////////////////////////////////lists page and settings page/////////////////////////////////////////////

//shows lists of liked/selected artists
void lists() {
  hideAll();

  c[11] = new ControlP5(this);
  c[11].setFont(artfontSS);

  ArrayList<String> likesnames = new ArrayList<String>();
  for (Artist a : likes) {
    likesnames.add(a.name);
  }

  int buffer = 10 - likesnames.size();
  for (int i = 0; i<buffer; i++) likesnames.add("");

  ArrayList<String> discover2 = new ArrayList<String>();
  for (Artist a : discover) {
    discover2.add(a.name);
  }

  int buffer2 = 10 - discover2.size();
  for (int i = 0; i<buffer2; i++) discover2.add("");

  Textarea ayl, ays;
  ScrollableList ayl2, ays2;

  c[11].addTextarea("username")
    .setPosition(100, 75)
    .setSize(450, 50)
    .setFont(DisplayFontL)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText(username + "'s list")
    .hideScrollbar()
    ;

  ayl = c[11].addTextarea("Ayl")
    .setPosition(100, 150)
    .setSize(300, 40)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Artists you Liked")
    .hideScrollbar() 
    ;

  ayl2 = c[11].addScrollableList("Ayl2")
    .setPosition(100, 185)
    .setSize(200, 350)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(likesnames)
    .setColor(SLcolors[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;

  ays = c[11].addTextarea("Ays")
    .setPosition(350, 150)
    .setSize(300, 40)
    .setFont(DisplayFontM)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Artists you selected")
    .hideScrollbar() 
    ;


  ays2 = c[11].addScrollableList("Ays2")
    .setPosition(350, 185)
    .setSize(200, 385)
    .setBarHeight(0)
    .setItemHeight(35)
    .addItems(discover2)
    .setColor(SLcolors[theme])
    .setType(ControlP5.LIST)
    .setBarVisible(false)
    ;

  //toggle between pages
  int buttonsize = 40;
  int buttonsizeBig = 150;
  int buttonspace = 5;
  c[11].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search0.png"))
    ;

  c[11].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list1.png"))
    ;

  c[11].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings0.png"))
    ;

  c[11].addButton("ExportLists")
    .setPosition((width-buttonsizeBig)/2, height-(2*buttonsize)-10)
    .setSize(buttonsizeBig, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/exportLists.png"))
    ;

  c[11].addButton("Reset")
    .setPosition((width-buttonsizeBig)/2, height-buttonsize)
    .setSize(buttonsizeBig, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/reset.png"))
    ;

  b[11] = true;
  c[11].show();
}

void ayl2(int n) {
}



void ExportLists() {
  if (b[11]) {
    int yesno = showConfirmDialog(null, "Do you want to export your lists? File will be saved as Your Lists.txt. The previous txt file will be overwritten.", "Export Lists", YES_NO_OPTION);
    if (yesno == 0) {
      PrintWriter output = createWriter("Your Lists.txt");
      output.println("Artists I Like");
      output.println("-------------------");
      for (Artist a : likes) output.println(a.getName());

      output.println();

      output.println("Artists I Selected");
      output.println("-------------------");
      for (Artist a : discover) output.println(a.getName());
      output.close();
      showMessageDialog(null, "Lists exported.", 
        "ExportList", PLAIN_MESSAGE);
    }
  }
}

void Reset() {
  if (b[11]) {
    int yesno = showConfirmDialog(null, "Do you want to reset the recommender? All lists and details will be deleted.", "Restart", YES_NO_OPTION);
    if (yesno == 0) {
      clearAllLists();
      state = 1;
      update =true;
    }
  }
}

//display setting options
void Settings() {
  hideAll();

  c[12] = new ControlP5(this);
  c[12].setFont(artfontSS);

  int side = 35;
  Textarea sett;


  sett = c[12].addTextarea("sett")
    .setPosition(side, 100)
    .setSize(width/2, 50)
    .setFont(DisplayFontL)
    .setColorValue(TAcolors[theme].getValueLabel())
    .setText("Settings")
    .hideScrollbar() 
    ;

  Textarea settoption;

  option = new ArrayList<String>();
  option.add(0, "Themes");

  option2 = new ArrayList<String>();
  option2.add(0, themeNames[theme]);

  ScrollableList settoption2;

  for (int i = 0; i<option.size(); i++) {


    c[12].addButton("optionOne" + i)
      .setPosition(side, 150+(i*(35+5)))
      .setSize(250, 35)
      .setImage(loadImage("Panel/" + theme + "/item" + i + ".png"))
      ;


    settoption = c[12].addTextarea("optionTwo" + i)
      .setPosition(side + 255, 150+(i*(35+5)))
      .setSize(150, 35)
      .setFont(DisplayFontM)
      .setColorValue(TAcolors[theme].getValueLabel())
      .setColorBackground(SLcolors2[theme].getForeground())
      .setText(option2.get(i))
      .hideScrollbar() 
      ;

    c[12].addButton("next" + i)
      .setPosition(side + 410, 150+(i*(35+5)))
      .setSize(35, 35)
      .setValue(i)
      .setImage(loadImage("Panel/" + theme + "/next.png"))
      ;
  } 


  //toggle between pages
  int buttonsize = 40;
  int buttonspace = 5;
  c[12].addButton("search")
    .setPosition(width-(3*buttonsize)-(2*buttonspace), 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/search0.png"))
    ;

  c[12].addButton("myLists")
    .setPosition(width-(2*buttonsize)-buttonspace, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/list0.png"))
    ;

  c[12].addButton("MySettings")
    .setPosition(width-buttonsize, 0)
    .setSize(buttonsize, buttonsize)
    .setImage(loadImage("Buttons/" + theme + "/settings1.png"))
    ;

  b[12] = true;
  c[12].show();
}

//switches back to search window(ie. not lists/settings)
void search() {

  switch(state) {


  case 11:
    if (b[11]) {
      state = Mstate;
      update = true;
    }
    break;

  case 12:
    if (b[12]) {
      state = Mstate;
      update = true;
    }
    break;
  }
}

//switches to lists page
void myLists() {
  switch(state) {

  case 11:
    break;

  case 3:
    if (b[3]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 4:
    if (b[4]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 5:
    if (b[5]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 6:
    if (b[6]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 8:
    if (b[8]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 9:
    if (b[9]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 10:
    if (b[10]) {
      Mstate = state;
      state = 11;
      update = true;
    }
    break;

  case 12:
    if (b[12]) {
      state = 11;
      update = true;
    }
    break;
  }
}

//switches to settings
void MySettings() {

  switch(state) {

  case 12:
    if (b[12]) {
    }
    break;


  case 3:
    if (b[3]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;

  case 4:
    if (b[4]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;

  case 5:
    if (b[5]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;

  case 6:
    if (b[6]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;

  case 8:
    if (b[7]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;

  case 9:
    if (b[9]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;

  case 10:
    if (b[10]) {
      Mstate = state;
      state = 12;
      update = true;
    }
    break;


  case 11:
    if (b[11]) {
      state = 12;
      update = true;
    }
    break;
  }
} 


///////////////////////////discovery//////////////////////////////

//compares tags with other artists
void discover() {
  int t1 = millis();
  calculateTag();
  topTags();
  discovername = new ArrayList<String>();
  d = new discoverThread[5];
  int i = 0;
  for (Map.Entry me : topFiveTags.entrySet() ) {
    d[i] = new discoverThread((String)me.getKey());
    d[i].start();
    i++;
  }

  for (discoverThread d2 : d) {
    try {
      d2.join();
    }
    catch(Exception e) {
    }
  }

  int t2 = millis();
  println("Time for discovery(250 max):" + (t2-t1));
}

//calculate average tag score
void calculateTag() {
  tagOverall = new HashMap<String, Integer>();

  ArrayList<Artist> combined = new ArrayList<Artist>();
  combined.addAll(likes);
  combined.addAll(discover);
  for (Artist a : combined) {
    for (Map.Entry me : a.getTags().entrySet()) {
      if (tagOverall.containsKey(me.getKey())) {
        int s = tagOverall.get(me.getKey());
        tagOverall.put((String)me.getKey(), s+(Integer)me.getValue());
      } else {
        tagOverall.put((String)me.getKey(), (Integer)me.getValue());
      }
    }
  }

  for (Map.Entry me : tagOverall.entrySet()) {
    int s2 = tagOverall.get(me.getKey())/combined.size();
    tagOverall.put((String)me.getKey(), s2);
  }

  for (Map.Entry me : tagOverall.entrySet()) {
    println(me.getKey()+ " " +me.getValue());
  }
}

//gets top 5 tags of all selected/liked artists
void topTags() {

  ArrayList<miniTag> mt = new ArrayList<miniTag>(); 
  ArrayList<miniTag> mt2 = new ArrayList<miniTag>(); 

  for (Map.Entry me : tagOverall.entrySet()) {
    miniTag m = new miniTag((String)me.getKey(), (int) me.getValue());
    mt.add(m);
  }


  int no = 5;
  if (mt.size()<= no) {
    mt2 = mt;
  } else {
    for (int j = 0; j<no; j++) {
      int big = mt.get(0).getCount();
      int index = 0;
      for (int i = 1; i<mt.size(); i++) {
        if (mt.get(i).getCount() > big) {
          big = mt.get(i).getCount();
          index = i;
        }
      }

      mt2.add(mt.get(index));
      mt.remove(mt.get(index));
    }
  }

  topFiveTags = new HashMap<String, Integer>();
  for (miniTag mt2b : mt2) {
    topFiveTags.put(mt2b.getName(), mt2b.getCount());
  }
}

//queries the api for similar artists
void loadDiscover(String s) {

  String query = s;
  String url = "http://ws.audioscrobbler.com/2.0/?method=tag.gettopartists&tag=" + query + "&api_key=5f89b5026e6206e9b74b93a117a4ef95&format=json&limit=201";

  JSONObject json = loadJSONObject(url);

  int ArtistSize =50;

  JSONArray json2 = json.getJSONObject("topartists").getJSONArray("artist");
  if (ArtistSize>json2.size()) ArtistSize=json2.size();


  for (int i = 0; i<ArtistSize; i++) {
    String query2 = json2.getJSONObject(i).getString("name");
    String query2b = "";

    try {
      query2b = URLEncoder.encode(query2, "UTF-8");
    }
    catch(Exception e) {
    }
    String url2 = "http://ws.audioscrobbler.com/2.0/?method=artist.gettopTags&artist=" + query2b + "&api_key=5f89b5026e6206e9b74b93a117a4ef95&format=json&limit=201";
    JSONObject json3 = loadJSONObject(url2);
    JSONArray json4 = json3.getJSONObject("toptags").getJSONArray("tag");
    int TagSize;


    TagSize = json4.size();
    if (TagSize>5) TagSize = 5;

    HashMap<String, Integer> h = new HashMap<String, Integer>();
    for (int j=0; j<TagSize; j++) {

      String name = json4.getJSONObject(j).getString("name");
      int count = json4.getJSONObject(j).getInt("count");

      h.put(name, count);
    }

    int counter = 0;
    for (Map.Entry me2 : h.entrySet()) {
      if (topFiveTags.containsKey(me2.getKey())) {
        if ((Integer)me2.getValue() >= (Integer)topFiveTags.get(me2.getKey())) {
          counter++;
        }
      }
    }

    if (counter >=3) {
      discovername.add(query2);
    }
  }
}

//gets youtube link for songs
public String yt(String url) {

  String yt = "nil"; 
  BufferedReader reader;

  String line;
  String check = "href=\"https://www.youtube.com/watch?";

  try {
    URL u = new URL(url);
    reader = new BufferedReader(new InputStreamReader(u.openStream()));
    while (reader.readLine()!=null) {
      line = reader.readLine();

      if (line.contains(check)) {
        yt = line;
        break;
      }
    }

    int a = yt.lastIndexOf("=");
    int b = yt.lastIndexOf("\"");
    yt = yt.substring(a+1, b);
  }


  catch (Exception e) {
  }

  return yt;
}

//launches youtube video
void launchPlayer(String url) {
  //save file and launch yt vid
  String[] t = new String[]{url};
  saveStrings("player/link.txt", t);
  launch(sketchPath("player/player.jar"));
}