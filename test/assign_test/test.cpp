#include <iostream>
#include <map>
#include <vector>
using namespace std;
double total_area(vector<double> h, vector<double> b) {
  double sum = 0;
  for (long long i = 0;;) {
    sum = sum + h.at(i) * b.at(i);

    i = i + 1;
    if (!()) {
    }
  };
  return sum;
}
int main() {
  vector<double> a, b;
  a.push_back(0.5);
  b.push_back(3);
  a.push_back(1.5);
  b.push_back(2);
  a.push_back(2.5);
  b.push_back(1);
  cout << total_area(a, b) << endl;
  return 1;
}
