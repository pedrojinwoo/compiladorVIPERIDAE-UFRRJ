int x;
x = 10;

func double(int x) : int {
  return (x * 2);
}
func triple(int x) : int{
  return (x * 3);
}

print(x);
x = double(x);
print(x);
x = triple(x);
print(x);