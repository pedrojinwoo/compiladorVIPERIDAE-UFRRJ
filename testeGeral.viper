int x;
int y;

duplicar(int x): int {
  y = x*2;
  return y;
}

x = 10;
y = 5;

print(x);
print(y);

int resultado;
resultado = duplicar(x);

print(x);
print(y);
print(resultado);