#include <iostream>
#include <map>
#include <vector>
using namespace std;
int main() {
  vector<int> marks;
  marks.push_back(10);
  marks.push_back(12);
  marks.push_back(11);
  // Push Back is equivalent to push_back
  // Pop_back is equivalent to a.back() and a. Pop_back
  cout << marks.back();
  marks.pop_back();
  cout << marks.back();
  // Push infront is equivalent to
  marks.insert(marks.begin(), 432);
  cout << marks.front();

  // Pop from infront is equivalent to
  // Use front to get the value at first
  cout << marks.front();
  marks.erase(marks.begin());
  cout << marks.front();
}
