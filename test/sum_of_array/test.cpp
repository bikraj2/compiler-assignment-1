#include <iostream>
#include <map>
#include <vector>
using namespace std;
int sumofArray(vector<int> a) {
  int sum = 0;
  int length = a.size();
  for (int i = 0; i < length;) {
    sum = sum + a.at(i);

    i = i + 1;
    if (!(i < length)) {
    }
  };
  return sum;
}
int main() {
  vector<int> array;
  array.push_back(10);
  array.push_back(10);
  array.push_back(10);
  array.push_back(10);
  array.push_back(10);
  cout << sumofArray(array) << endl;
  return 1;
}
