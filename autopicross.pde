import java.util.Arrays;

int rows = 5, cols = 5, boardLength, rowSlider = 300, colSlider = 300, rowEdit, colEdit;
boolean editingRow = false, editingCol = false;
float squareSize;

ArrayList<ArrayList<Integer>> rowNums, colNums;

enum tile{EMPTY, FILLED, CROSSED, TEMPFILLED, TEMPCROSSED};
tile[][] board;

void setup(){
  fullScreen();
  textAlign(LEFT, TOP);
  
  boardLength = height*3/5;
  squareSize = boardLength/rows;
  
  rowNums = new ArrayList();
  colNums = new ArrayList();
  fillList(rowNums, rows);
  fillList(colNums, cols);
  
  board = new tile[rows][cols];
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < cols; j++){
      board[i][j] = tile.EMPTY;
    }
  }
}

void draw(){
  background(255);
  
  //draw sliders
  textSize(50);
  fill(0);
  text(String.format("Rows: %d", rows), 40, 50);
  text(String.format("Cols: %d", cols), 40, 120);
  fill(150);
  rect(300, 50, 500, 50);
  rect(300, 120, 500, 50);
  fill(0);
  square(rowSlider, 50, 50);
  square(colSlider, 120, 50);
  
  //solve button
  fill(0, 255, 0);
  rect(300, 250, 400, 50);
  fill(0);
  text("Solve", 430, 245);
  
  //draw numbers
  fill(0);
  textSize(squareSize*0.8);
  for(int i = 0; i < rowNums.size(); i++){
    for(int j = 0; j < rowNums.get(i).size(); j++){
       text(rowNums.get(i).get(rowNums.get(i).size()-j-1),  width*3/5 - ((1+j)*squareSize), height/3 + (i*squareSize));
    }
  }
  for(int i = 0; i < colNums.size(); i++){
    for(int j = 0; j < colNums.get(i).size(); j++){
       text(colNums.get(i).get(colNums.get(i).size()-j-1),  width*3/5 + (i*squareSize), height/3 - ((1+j)*squareSize));
    }
  }
  
  //highlight row/column
  noStroke();
  fill(255, 255, 0, 50);
  if(mouseX > width*3/5 && mouseX < width*3/5 + cols*squareSize && mouseY < height/3){
    int temp = int((mouseX - width*3/5) / (squareSize));
    square(width*3/5 + (temp*squareSize), height/3-squareSize, squareSize);
  }
  if(mouseY > height/3 && mouseY < height/3 + rows*squareSize && mouseX <  width*3/5){
    int temp = int((mouseY - height/3) / (squareSize));
    square(width*3/5-squareSize, height/3 + (temp*squareSize), squareSize);
  }
  
  //draw board
  stroke(1);
  translate(width*3/5, height/3);
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(board[j][i] == tile.FILLED){
        fill(10);
      }
      else{
        fill(255);
      }
      square(i*squareSize, j*squareSize, squareSize);
      if(board[j][i] == tile.CROSSED){
        fill(0);
        line(i*squareSize, j*squareSize, (i+1)*squareSize, (j+1)*squareSize);
        line((i+1)*squareSize, j*squareSize, i*squareSize, (j+1)*squareSize);
      }
    }
  }
}

void mouseDragged(){
  if(mouseX > 325 && mouseX < 775 && mouseY > 50 && mouseY < 100){ //slider to change number of rows
    rowSlider = mouseX-25;
    rows = int((rowSlider-300)/11.25)+1;
    fillList(rowNums, rows);
    board = new tile[rows][cols];
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        board[i][j] = tile.EMPTY;
      }
    }
    squareSize = boardLength/max(rows, cols);
  }
  if(mouseX > 325 && mouseX < 775 && mouseY > 120 && mouseY < 170){ //slider to change number of columns
    colSlider = mouseX-25;
    cols = int((colSlider-300)/11.25)+1;
    fillList(colNums, cols);
    board = new tile[rows][cols];
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        board[i][j] = tile.EMPTY;
      }
    }
    squareSize = boardLength/max(rows, cols);
  }
}

void mousePressed(){
  if(mouseX > width*3/5 && mouseX < width*3/5 + cols*squareSize && mouseY < height/3){ //editing column numbers
    colEdit = int((mouseX - width*3/5) / (squareSize));
    editingCol = true;
    editingRow = false;
    colNums.get(colEdit).clear();
    colNums.get(colEdit).add(0);
  }
  if(mouseY > height/3 && mouseY < height/3 + rows*squareSize && mouseX <  width*3/5){ //editing row numbers
    rowEdit = int((mouseY - height/3) / (squareSize));
    editingRow = true;
    editingCol = false;
    rowNums.get(rowEdit).clear();
    rowNums.get(rowEdit).add(0);
  }
  
  if(mouseX > width*3/5 && mouseX < width*3/5 + cols*squareSize && mouseY > height/ 3&& mouseY < height/3 + rows*squareSize){ //editing board
    colEdit = int((mouseX - width*3/5) / (squareSize));
    rowEdit = int((mouseY - height/3) / (squareSize));
    if(mouseButton == LEFT){
      board[rowEdit][colEdit] = board[rowEdit][colEdit] == tile.FILLED ? tile.EMPTY : tile.FILLED; //left click fill tile
    }
    else{
      board[rowEdit][colEdit] = board[rowEdit][colEdit] == tile.CROSSED ? tile.EMPTY : tile.CROSSED; //right click cross tile
    }
  }
  
  if(mouseX > 300 && mouseX < 700 && mouseY > 250 && mouseY < 300){ //solve button pressed
    solve();
  }
}

void keyPressed(){
  if(editingRow || editingCol){
    ArrayList<Integer> editing = null; //the row the we are editing
    if(editingRow) editing = rowNums.get(rowEdit);
    else           editing = colNums.get(colEdit);
    switch(key){
      case(ENTER): //stop editing
        editingRow = false;
        editingCol = false;
        break;
        
      case(BACKSPACE): //remove last number
        if(!editing.isEmpty()) editing.remove((int) editing.size()-1);
        if(editing.isEmpty()) editing.add(0);
        break;
        
      case(' '): //SPACE - next number
        editing.add(0);
        break;
      
      default:
        if(key-'0' >= 0 && key-'0' <= 9) //write number
          editing.set(editing.size()-1, 10*editing.get(editing.size()-1) + key-'0');
    }
  }
}

//fills an ArrayList of ArrayLists with the amount of empty arraylists specified by the input capacity
void fillList(ArrayList list, int cap){
  list.clear();
  for(int i = 0; i < cap; i++){
     list.add(new ArrayList<Integer>()); 
  }
}

//print everything because im tried of writing System.out.println()
void pprint(Object p){
  if(p instanceof String) System.out.println(p);
  else if(p instanceof ArrayList) System.out.println(p.toString());
  else if(p.getClass().isArray()) {
    Object[] a = (Object[]) p;
    if(a[0].getClass().isArray()){ 
      for(boolean[] b : (boolean[][]) a) System.out.println(Arrays.toString(b));
    }
    else System.out.println(Arrays.toString(a));
  }
  else{
    try{
      System.out.println(p);
    }
    catch(Exception e){
      System.out.println("Cannot be printed");
    }
  }
}
