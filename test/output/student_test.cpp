#include <iostream>
#include <map>
#include <vector>
using namespace std;
long long student_grade(long long marks, long long highestmarks) {
  long long grade_status;
  if (marks >= 90) {
    grade_status = 2;
    if (marks == highestmarks) {
      grade_status = 1;
    }
  } else if (marks >= 80) {
    grade_status = 3;
  } else if (marks >= 70) {
    grade_status = 3;
  } else if (marks >= 60) {
    grade_status = 4;
  } else if (marks >= 50) {
    grade_status = 5;
  } else if (marks >= 40) {
    grade_status = 6;
  } else if (marks >= 30) {
    grade_status = 7;
  } else {
    grade_status = 0;
  }
  return grade_status;
}
int main() {
  long long marks = 85;
  long long highestmarks = 98;
  long long grade_status = student_grade(marks, highestmarks);
  cout << grade_status << endl;
  return 1;
}
