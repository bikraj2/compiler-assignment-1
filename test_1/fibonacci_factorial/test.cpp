#include <iostream>
#include <map>
#include <vector>
using namespace std;
long long fibonacci(long long n) {
  long long a = 0;
  long long b = 1;
  long long next;
  for (long long i = 2; i <= n;) {
    next = a + b;
    a = b;
    b = next;

    i = i + 1;
    if (!(i <= n)) {
    }
  };
  return b;
}
long long factorial(long long n) {
  long long fact = 1;
  for (long long i = 1; i <= n;) {
    fact = fact * i;

    i = i + 1;
    if (!(i <= n)) {
    }
  };
  return fact;
}
int main() {
  long long n = 5;
  cout << fibonacci(n) << endl;
  cout << factorial(n) << endl;
  return 1;
}
