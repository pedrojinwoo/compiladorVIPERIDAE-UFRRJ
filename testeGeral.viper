int I;
I = 0;
while(I<5) {
  I = I+1;
  print(1);
  while(I<5){
    I = I+1;
    print(2);
    while(I<5) {
      I = I+1;
      print(3);
      break all;
    }
  }
}