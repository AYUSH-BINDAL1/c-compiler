void foo(long a, long b, long c, long d, long e, long f)
{
    printf("%d\n", a);
    printf("%d\n", b);
    printf("%d\n", c);
    printf("%d\n", d);
    printf("%d\n", e);
    printf("%d\n", f);
}

void main() {
  long a;
  a = 0;

  long b;
  b = 1;

  long c;
  c = 2;

  long d;
  d = 3;

  long e;
  e = 4;

  long f;
  f = 5;

  foo(a, b, c, d, e, f);
}
