import controlP5.*;
import java.awt.*;
import javax.swing.*;
import processing.video.*;
Movie myMovie;

final int Bheight = 144; //四角形の高さ
final int Bwidth = Bheight/9*16-10; //四角形の幅 
final int COLS = 5, ROWS = 5;
final int PLAYER_NUM = 4;
int History = 0;
int[][][] field;
int currentColor = 1;
int lastColor = 1;
boolean dFQ = false;

ControlP5 cp5;
CheckBox checkbox;
CheckBox accheckbox;
RadioButton r;


void setup(){
  size(1280,720,P2D);  
  myMovie = new Movie(this, "flight-chance.mov");

  colorMode(RGB);
  field = new int[COLS][ROWS][256];
  cp5 = new ControlP5(this);
   cp5.setBroadcast(false);
   cp5.addButton("UNDO")
     .setValue(0)
     .setPosition(1235,height-25)
     .setSize(40,20)
     ;  
  
  cp5.addButton("PLAY")
     .setValue(0)
     .setPosition(1235,height-50)
     .setSize(40,20)
     ;  
  
  checkbox = cp5.addCheckBox("checkBox") //アタックチャンスボタン
                .setPosition(1235, 150 )
                .setColorForeground(color(200))
                .setColorActive(color(255))
                .setColorLabel(color(255))
                .setSize(20, 20)
                .setItemsPerRow(1)
                .addItem("AC", 5)
                ; 
                

    //色選択ラジオボタン
    r = cp5.addRadioButton("radioButton")
         .setPosition(1235,20)
         .setSize(20,20)
         .setColorForeground(color(200))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         .addItem("R",1)
         .addItem("G",2)
         .addItem("W",3)
         .addItem("B",4)
         .activate(0);
         ;
  cp5.setBroadcast(true);

     
  //石をおいてない状態にリフレッシュ
  for(int i=0; i<COLS; ++i){
    for(int j=0; j<ROWS; ++j){
      field[i][j][History] = 0;
    }
  }
  
}
 
void draw(){
  //draw field
  background(64);
  stroke(0);
  
  //右のメニュー画面を描画
  fill(0,0,0);
  rect(1230,0, width-1, 720);
  if(dFQ == true){
    image(myMovie, 0, 0,1230,720);
  }

  //各マスの石を描画
  //noStroke();
  for(int i=0; i<COLS; ++i){
    for(int j=0; j<ROWS; ++j){
        switch(field[i][j][History]) {
            case 0: //empty
              fill(125,125,125,255);
              stroke(0,0,0,255);
              break;
            case 1: //Red
              fill(255,0,0,255);
              stroke(0,0,0,255);
              break;
            case 2: //Green
              fill(0,255,0,255);
              stroke(0,0,0,255);
              break;
            case 3: //White
              fill(255,255,255,255);
              stroke(0,0,0,255);
              break;
            case 4: //Blue
              fill(0,0,255,255);
              stroke(0,0,0,255);
              break;
            case 5: //AChance
              fill(255,255,0,255);
              stroke(0,0,0,255);
              break;
            case 6: //Winner
              fill(0,0,0,0);
              stroke(0,0,0,0);
              break;
          } 
          rect(i*Bwidth+1,j*Bheight+1, Bwidth-1, Bheight-1);
    }
  }

  if(dFQ == false){
    //グリッドの数字を描画
    int dispnum = 1;
    for(int i=0;i<5;i++){
      for(int j=0;j<5;j++){
        textSize(24);
        textAlign(CENTER,CENTER);
        fill(#000000);
        text(dispnum,Bwidth/2+(Bwidth*j),Bheight/2+(Bheight*i));
        dispnum++;
      }
    }
  }
}
 
 //スイッチ類のハンドラ
void controlEvent(ControlEvent theEvent) {
  //勝者決定時のムービー再生
  if (theEvent.isFrom("PLAY")){
    println(theEvent.getController().getName());
  //勝者の石を消す
  for(int i=0; i<COLS; ++i){
    for(int j=0; j<ROWS; ++j){
     if(field[i][j][History] == currentColor){
      field[i][j][History] = 6;
     }
    }
  }
    dFQ=true;
    myMovie.jump(1);
    myMovie.play();
  }
  else if (theEvent.isFrom("UNDO")){
    println(theEvent.getController().getName());
    History--;
  }
  else if (theEvent.isFrom(checkbox)) {
    print("got an event from "+checkbox.getName()+"\t");
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    println(checkbox.getArrayValue());
    for (int i=0;i<checkbox.getArrayValue().length;i++) {
      int n = (int)checkbox.getArrayValue()[i];
      print(n);
    }
    println();
    if(checkbox.getArrayValue()[0] == 1){
      r.deactivateAll();
      currentColor = 5;
    }
    else {
    }
      
  }
  else if(theEvent.isFrom(r)) {
    print("got an event from "+theEvent.getName()+"\t");
    for(int i=0;i<theEvent.getGroup().getArrayValue().length;i++) {
      print(int(theEvent.getGroup().getArrayValue()[i]));
    }
    println("\t "+theEvent.getValue());
    currentColor=int(theEvent.getValue());

  }
}

 
void mouseReleased(){
  int x = mouseX/Bwidth;
  int y = mouseY/Bheight; //<>//
 //println(checkbox.getArrayValue());
 if (x < 5){
 //基準点を中心に８方向へチェック＆色替えしていき、どれかOKなら基準点をその色にする
 //縦棒はビット演算子(or)
  boolean puttable = false;
  if(field[x][y][History]== 0 || field[x][y][History]==5 || checkbox.getArrayValue()[0] == 1){
  //次の状態にコピー
  for(int i=0; i<COLS; ++i){
    for(int j=0; j<ROWS; ++j){
      field[i][j][History+1] = field[i][j][History];
    }
  }

    //置こうとしている場所が空若しくはアタックチャンスの時
    puttable = checkDirection(x,y,-1,-1) | puttable;
    puttable = checkDirection(x,y,-1,0) | puttable;
    puttable = checkDirection(x,y,-1,1) | puttable;
 
    puttable = checkDirection(x,y,0,-1) | puttable;
    puttable = checkDirection(x,y,0,1) | puttable;
 
    puttable = checkDirection(x,y,1,-1) | puttable;
    puttable = checkDirection(x,y,1,0) | puttable;
    puttable = checkDirection(x,y,1,1) | puttable;
 


      field[x][y][History+1] =currentColor;
      if(currentColor == 5){
        checkbox.deactivate(0);
      }
      History++; 

  }
 }
}
 
boolean checkDirection(int x, int y, int directionX, int directionY){
  //置こうとした場所の隣にたいして　境界から外れていない　＆　同じ色でない　＆　空マスでないかチェックして、問題なければcheckStoneへ
  if(checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY][History] != currentColor && field[x+directionX][y+directionY][History] != 0){
    return checkStones(x, y, directionX, directionY);
  }
  return false;
}
 
 //こいつがネストしていてチェックしている
boolean checkStones(int x, int y, int directionX, int directionY){
  if(checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY][History]==currentColor){ // 枠からはみ出ていないかつソッチの方へ見ていった後石が見つかったので、置いてよしを返す
    return true;
  }else if(checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY][History]==0){ // 空の領域が見つかったらだめを返す
    return false;
  }else if(checkBound(x+directionX, y+directionY) && checkStones(x+directionX, y+directionY, directionX, directionY)){  //上記以外の時はさらに先の領域を再帰検索
    field[x+directionX][y+directionY][History+1] = currentColor; // チェックしたところを自分の色にする（基準点は上記メソッドにてチェック）
    return true;
  }else{
    return false; //その他の時は置かない
  }
}
 
 //枠の外にはみ出てないかチェックするメソッド
boolean checkBound(int x, int y){
  return x>=0 && x<COLS && y>=0 && y<ROWS;
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
