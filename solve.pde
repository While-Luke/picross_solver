//The solving algorithm works by finding all valid row/column configurations, one at a time, and using that to determine which tiles will always be filled, and which ones will always be crossed
//We can determine which tiles must be filled by first assuming that all tiles will be filled, then if we find a valid solution to a row in which a certain tile is not filled, we store the fact that we
//don't know its value, then at the end of finding all valid rows, see which tiles we are still sure must be filled. Same idea goes for crossing them

void solve(){
  //first check that all rows and columns contain numbers
  for(ArrayList<Integer> temp : rowNums){
    if(temp.size() == 0) return;
  }
  for(ArrayList<Integer> temp : colNums){
    if(temp.size() == 0) return;
  }
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < cols; j++){
      board[i][j] = tile.EMPTY; //clear board
    }
  }
  
  //then fill in rows/columns with either all crosses or all filled
  boolean[] completeRows = new boolean[rows];
  boolean[] completeCols = new boolean[cols];
  
  for(int i = 0; i < rows; i++){
    if(rowNums.get(i).get(0) == cols){
      for(int j = 0; j < cols; j++){
        board[i][j] = tile.FILLED;
      }
      completeRows[i] = true;
    }
    if(rowNums.get(i).get(0) == 0){
      for(int j = 0; j < cols; j++){
        board[i][j] = tile.CROSSED;
      }
      completeRows[i] = true;
    }
  }
  
  for(int j = 0; j < cols; j++){
    if(colNums.get(j).get(0) == rows){
      for(int i = 0; i < rows; i++){
        board[i][j] = tile.FILLED;
      }
      completeCols[j] = true;
    }
    if(colNums.get(j).get(0) == 0){
      for(int i = 0; i < rows; i++){
        board[i][j] = tile.CROSSED;
      }
      completeCols[j] = true;
    }
  }
  
  //finally start the main part of the algorithm of finding and checking every valid row/column configuration in a loop
  while(containsFalse(completeRows) && containsFalse(completeCols)){
    //check all rows
    for(int i = 0; i < rows; i++){
      if(completeRows[i]) continue;
      
      ArrayList<Integer> currentNums = rowNums.get(i);
      tile[] row = new tile[cols];
      for(int j = 0; j < cols; j++) row[j] = board[i][j];
      boolean[][] notknown = new boolean[cols][2]; //0 = filled, 1 = crossed
      enumerateLine(row, 0, currentNums, 0, notknown); //check all possible row configurations
      for(int j = 0; j < cols; j++){
        if(board[i][j] == tile.EMPTY && !notknown[j][0]) board[i][j] = tile.FILLED; 
        if(board[i][j] == tile.EMPTY && !notknown[j][1]) board[i][j] = tile.CROSSED;
      }
    }

    //check all columns
    for(int j = 0; j < cols; j++){
      if(completeCols[j]) continue;
      
      ArrayList<Integer> currentNums = colNums.get(j);
      tile[] col = new tile[rows];
      for(int i = 0; i < rows; i++) col[i] = board[i][j];
      boolean[][] notknown = new boolean[rows][2]; //0 = filled, 1 = crossed
      enumerateLine(col, 0, currentNums, 0, notknown); //check all possible column configurations
      
      for(int i = 0; i < rows; i++){
        if(board[i][j] == tile.EMPTY && !notknown[i][0]) board[i][j] = tile.FILLED; //if the notknown value of the tile if false, that means it is known and thus must be filled
        if(board[i][j] == tile.EMPTY && !notknown[i][1]) board[i][j] = tile.CROSSED;
      }
    }
    
    for(int i = 0; i < rows; i++){
      if(completeRows[i]) continue;
      boolean complete = true;
      for(int j = 0; j < cols; j++){
        if(board[i][j] == tile.EMPTY){
          complete = false;
        }
      }
      completeRows[i] = complete;
    }
    for(int j = 0; j < cols; j++){
      if(completeCols[j]) continue;
      boolean complete = true;
      for(int i = 0; i < rows; i++){
        if(board[i][j] == tile.EMPTY){
          complete = false;
        }
      }
      completeCols[j] = complete;
    }
  }
}


/**
 * Enumerates through all the possible configurations of a row/column of the board given the numbers associated.
**/
void enumerateLine(tile[] row, int start, ArrayList<Integer> nums, int index, boolean[][] notknown){
  for(int i = start; i <= row.length-nums.get(index); i++){
    if(row[i] == tile.EMPTY || row[i] == tile.FILLED){
      boolean enoughSpace = true;
      for(int k = 0; k < nums.get(index); k++){ //check if there is enough space for the number to fit
        if(row[i+k] == tile.CROSSED){
          enoughSpace = false;
          break;
        }
      }
      if(!enoughSpace) continue;
      tile[] store = new tile[nums.get(index)]; //if true then temp fill
      for(int k = 0; k < nums.get(index); k++){
        store[k] = row[i+k];
        row[i+k] = tile.TEMPFILLED; 
      }
      
      if(index+1 == nums.size()){
        if(valid(row, nums)){ //check valid rows
          for(int j = 0; j < row.length; j++){
            if(row[j] == tile.TEMPFILLED || row[j] == tile.FILLED) notknown[j][1] = true;
            if(row[j] == tile.EMPTY || row[j] == tile.CROSSED) notknown[j][0] = true;
          }
        }
      }
      else{
        enumerateLine(row, i+nums.get(index), nums, index+1, notknown); //move to next number
      }
      for(int k = 0; k < nums.get(index); k++) row[i+k] = store[k]; //undo TEMPFILLED squares
    }
  }
}

//Returns true if the given row matches the list the numbers associated with it
boolean valid(tile[] row, ArrayList<Integer> nums){
  int count, index = 0;
  for(int i = 0; i < row.length; i++){
    if(row[i] == tile.FILLED || row[i] == tile.TEMPFILLED){
      count = 0;
      while(i < row.length && (row[i] == tile.FILLED || row[i] == tile.TEMPFILLED)){
        count++;
        i++;
      }
      if(index >= nums.size() || count != nums.get(index)) return false;
      index++;
    }
  }
  if(index != nums.size()) return false;
  return true;
}

//return true if an array of booleans contains a false value
boolean containsFalse(boolean[] a){
  for(boolean b : a){
    if(!b) return true;
  }
  return false;
}
