#include <iostream>
#include <map>

int main() {
  std::map<int, int> there;
  there[10] = 10;
  std::cout << there.at(10);
}
