#include <iostream>
#include <map>
#include <vector>
using namespace std;
long long student_pass(long long marks) {
  long long status;
  if (marks > 60) {
    status = 1;
  }
  elseif(marks > 70  à€4Øİ ) { status = 2; }
  elseif(marks > 80  4Øİ ) { status = 3; }
  elseif(marks > 90 @4Øİ ) { status = 4; }
  else {
    status = 0;
  }
  return status;
}
int main() { return 1; }
