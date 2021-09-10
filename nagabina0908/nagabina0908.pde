import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import twitter4j.*;
import twitter4j.util.*;
import twitter4j.util.function.*;
import twitter4j.auth.*;
import twitter4j.management.*;
import twitter4j.json.*;
import twitter4j.api.*;
import twitter4j.conf.*;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.io.File;
import java.nio.file.FileSystems;
import java.nio.file.FileSystem;

import javax.swing.*;
import java.awt.*;

Minim minim;
AudioPlayer bgm;
AudioSample start;
AudioSample complete;

JLayeredPane pane;
JTextArea area;

int red;
int green;
int blue;
float x[] = new float[100];
float y[] = new float[100];
float r[] = new float[100];
float a[] = new float[100];
float b[] = new float[100];
float c[] = new float[100];
PFont font;
boolean overSButton = false;
boolean overTButton = false;
boolean overEButton = false;
boolean overOButton = false;
int alpSB=75;
int alpTB=75;
int alpEB=75;
int alpOB = 75;
int mode=0;

String contents[]=new String[2];

String tweet = "";
File pic_file;

String c_key = "XXXXX";
String c_secret = "XXXXX";
String a_token = "XXXXX";
String a_secret = "XXXXX";
Twitter twitter;

float time_count = 0;
float prev_time = 0;

PImage hina, fuku;
int fukuR, fukuG, fukuB;
int hinaW = 700;
int hinaH = 700;

Path txt;
Path pic;
boolean txtExists;
boolean picExists;

boolean tweeted = false;

void setup()
{
  size(640, 480);

  minim = new Minim(this);
  bgm = minim.loadFile("Ureshii_Hinamatsuri.mp3");  // BGM
  // 効果音
  start = minim.loadSample("start.wav");  // ボタンを押したとき
  complete = minim.loadSample("complete.wav"); // 願い事決定時
  bgm.loop();

  // SmoothCanvasの親の親にあたるJLayeredPaneを取得
  Canvas canvas = (Canvas) surface.getNative();
  pane = (JLayeredPane) canvas.getParent().getParent();

  red=255;
  green=255;
  blue=255;
  for (int i=0; i<100; i++) {
    x[i]=random(700);
    y[i]=random(700);
    r[i]=random(5, 40);
    a[i]=random(200);
    b[i]=random(200);
    c[i]=random(200);
  }
  font=createFont("HGS教科書体", 64);//createFont("フォントの名前", フォントの大きさ)
  textFont(font);//フォントを指定
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  imageMode(CENTER);

  // 雛人形の画像を読み込み
  hina=loadImage("nagashibina.png");
  fuku=loadImage("fuku.png");

  //　過去のツイート用ファイルを削除
  txt = Paths.get(dataPath("tweet_file.txt"));
  pic = Paths.get(dataPath("tweet_pic.png"));
  try {
    Files.delete(txt);
  }
  catch(IOException e) {
    System.out.println(e);
  }
  try {
    Files.delete(pic);
  }
  catch(IOException e) {
    System.out.println(e);
  }
  txtExists = new File(dataPath("tweet_file.txt")).exists();
  picExists = new File(dataPath("tweet_pic.png")).exists();
}

void draw()
{
  background(red, green, blue);
  red=(red+1)%256;
  green=(green+2)%256;
  blue=(blue+3)%256;
  noStroke();
  for (int i=0; i<100; i++) {
    fill(a[i], b[i], c[i]);
    ellipse(x[i], y[i], r[i], r[i]);
    x[i]=x[i]+r[i]/150+c[i]/180;
    if (x[i]-r[i]>width) x[i]=x[i]-700;
  }
  if (mode==0)
  {
    titleLogo();
    startButton();
  } else if (mode==1)
  {
    request();
    tweetButton();
    // 文字数制限
    if (area.getText().length() > 115) {
      area.setText(area.getText().substring(0, 115));
    }
  } else if (mode==2 || mode==3) 
  {
    hinaShow();
    if (txtExists == false && picExists == false) {
      hinaColorDecide();
      hinaShow();
      hinaSave();
      txtExists = new File(dataPath("tweet_file.txt")).exists();
      picExists = new File(dataPath("tweet_pic.png")).exists();
    }
    if (txtExists == true && picExists == true) {
      mode = 3;
      if (tweeted == false) {
        tweetSetup();
        tweet();
        tweeted = true;
      }
    }
  }
  if (mode==3) {
    endButton();
    othersButton();
  }
}


void mouseMoved() // ボタン判定起動
{
  checkButtons();
}

void mouseDragged() // ボタン判定起動
{
  checkButtons();
}

void mousePressed()
{
  if (mode==0)
  {
    if (overSButton)
    {
      textAreaSet();
      start.trigger();
      mode=1;
    }
  } else if (mode==1)
  {
    if (overTButton)
    {
      makeTxt();
      complete.trigger();
      mode=2;
    }
  } else if (mode==3) {
    if (overEButton) {
      start.trigger();
      delay(1000);
      exit();
    }
    if (overOButton) {
      start.trigger();
      link("https://twitter.com/ngsbn_online");
    }
  }
  //println("X "+mouseX+" Y "+mouseY);
}

void titleLogo() // タイトルロゴ
{
  fill(0, 75);
  rect(width/2, height/2-120, 600, 180);
  fill(255);
  textSize(64);
  text("流し雛        \n  オンライン", width/2, height/2-120);
}

void startButton() // スタートボタン
{
  if (overSButton)
  {
    if (alpSB>45)
      alpSB-=2;
  } else
  {
    if (alpSB<75)
      alpSB+=2;
  }
  fill(0, alpSB);
  rect(width/2, height/2+120, 300, 90);
  fill(255);
  textSize(48);
  text("はじめる", width/2, height/2+120);
}

void request() // メッセージ入力を促す
{
  fill(0, 75);
  rect(width/2, height/2-150, 600, 90);
  fill(255);
  textSize(64);
  text("願い事を書こう！", width/2, height/2-150);
}

void tweetButton() // 投稿ボタン
{
  if (overTButton)
  {
    if (alpTB>45)
      alpTB-=2;
  } else
  {
    if (alpTB<75)
      alpTB+=2;
  }
  fill(0, alpTB);
  rect(width/2, height/2+150, 200, 90);
  fill(255);
  textSize(48);
  text("流す", width/2, height/2+150);
}

void checkButtons() // ボタンの判定まとめ
{
  if (mode==0) {
    if (mouseX > 170 && mouseX < 470 && mouseY > 315 && mouseY < 405) {
      overSButton = true;
    } else {
      overSButton = false;
    }
  }
  if (mode==1) {
    if (mouseX > 220 && mouseX < 420 && mouseY > 345 && mouseY < 435) {
      overTButton = true;
    } else {
      overTButton = false;
    }
  }
  if (mode==3) {
    // 終了ボタン
    if (mouseX > 420 && mouseX < 620 && mouseY > 375 && mouseY < 465) {
      overEButton = true;
    } else {
      overEButton = false;
    }
    // 「みんなの流し雛」ボタン
    if (mouseX > 25 && mouseX < 375 && mouseY > 375 && mouseY < 465) {
      overOButton = true;
    } else {
      overOButton = false;
    }
  }
}

void textAreaSet() // テキストエリアの表示
{
  area = new JTextArea();
  area.setFont(new Font("HGS教科書体", Font.PLAIN, 30));
  area.setLineWrap(true);
  area.setWrapStyleWord(true);
  JScrollPane scrollPane = new JScrollPane(area);
  scrollPane.setBounds(100, 160, 440, 160);
  pane.add(scrollPane);
}

void makeTxt() // txtの生成
{
  contents[0] = "誰かが願い事「" + area.getText() + "」から生まれた流し雛を流しました！";
  contents[1] = "#流し雛オンライン";
  saveStrings(dataPath("tweet_file.txt"), contents);
  //launch(sketchPath("nagashibina_post.pde"));
  //println("Done!");
  //println("投稿プログラムを起動");
  //exit();
}

void tweetSetup() {
  String[] lines = loadStrings("tweet_file.txt");
  for (int i=0; i<lines.length; i++) {
    tweet = tweet + "\n" + lines[i];
  }

  FileSystem fs = FileSystems.getDefault();
  Path path = fs.getPath(dataPath("tweet_pic.png"));
  pic_file = path.toFile();

  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey(c_key);
  cb.setOAuthConsumerSecret(c_secret);
  cb.setOAuthAccessToken(a_token);
  cb.setOAuthAccessTokenSecret(a_secret);
  twitter = new TwitterFactory(cb.build()).getInstance();
}

void tweet() {
  try {
    twitter.updateStatus(new StatusUpdate(tweet).media(pic_file));
    println("Done!");
  } 
  catch(TwitterException e) {
    println("Error!");
  }
  pane.remove(0);
}

IntList strToNum(String str)  // 文字列を１文字ごとに文字コードにする
{
  IntList list = new IntList();
  for (int i=0; i<str.length(); i++) {
    char c = str.charAt(i);
    list.append(c);
  }
  return list;
}

void hinaColorDecide()  // 流し雛の色を決定
{
  IntList num_list;
  num_list = strToNum(area.getText());
  for (int i=0; i<num_list.size(); i++) {
    if (i % 3 == 0) {
      fukuR += num_list.get(i);
    } else if (i % 3 == 1) {
      fukuG += num_list.get(i);
    } else if (i % 3 == 2) {
      fukuB += num_list.get(i);
    }
  }
  fukuR %= 256;
  fukuG %= 256;
  fukuB %= 256;
}

void hinaShow()  // 流し雛の画像を表示
{
  // 流し雛を表示
  noTint();
  image(hina, width/2, height/2, hinaW/2, hinaH/2);
  tint(fukuR, fukuG, fukuB);
  image(fuku, width/2, height/2, hinaW/2, hinaH/2);
}

void hinaSave() {
  PImage img=createImage(width, height, RGB);
  // 画面を画像にコピー
  loadPixels();
  img.pixels = pixels;
  img.updatePixels();

  //画像のピクセル情報を切り出して保存
  img = img.get(0, 0, width, height); // ここを弄って保存領域を決める
  img.save(dataPath("tweet_pic.png"));
}

void endButton()  // 終了ボタン
{
  if (overEButton)
  {
    if (alpEB>45)
      alpEB-=2;
  } else
  {
    if (alpEB<75)
      alpEB+=2;
  }
  fill(0, alpEB);
  rect(width/2+200, height/2+180, 200, 90);
  fill(255);
  textSize(48);
  text("終了", width/2+200, height/2+180);
}


void othersButton()  // 「みんなの流し雛」ボタン
{
  if (overOButton)
  {
    if (alpOB>45)
      alpOB-=2;
  } else
  {
    if (alpOB<75)
      alpOB+=2;
  }
  fill(0, alpOB);
  rect(width/2-120, height/2+180, 350, 90);
  fill(255);
  textSize(48);
  text("みんなの流し雛", width/2-120, height/2+180);
}
