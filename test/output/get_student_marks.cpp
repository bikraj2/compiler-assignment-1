#include <iostream>
#include <map>
#include <vector>
using namespace std;
vector<float> createScoreMap(map<int, vector<float>> scoreMap,
                             vector<int> rolls) {
  vector<float> percentage;
  for (int i = 0; i < rolls.size();) {
    float sum = 0;
    vector<float> scores;
    scores = scoreMap.at(rolls.at(i));
    for (int j = 0; j < scores.size();) {
      sum = sum + scores.at(j);

      j = j + 1;
      if (!(j < scores.size())) {
      }
    };
    percentage.push_back(sum / 300);
    i = i + 1;
    if (!(i < rolls.size())) {
    }
  };
  return percentage;
}
int main() {
  map<int, vector<float>> studentMarks;
  int maxMarks = 300;
  vector<float> marks101;
  vector<float> marks102;
  vector<float> marks103;
  marks101.push_back(85);
  marks101.push_back(90);
  marks101.push_back(78);
  marks102.push_back(70);
  marks102.push_back(60);
  marks102.push_back(80);
  marks103.push_back(95);
  marks103.push_back(88);
  marks103.push_back(92);
  vector<int> rolls;
  rolls.push_back(101);
  rolls.push_back(102);
  rolls.push_back(103);
  studentMarks[101] = marks101;
  studentMarks[102] = marks102;
  studentMarks[103] = marks103;
  vector<float> percentages;
  percentages = createScoreMap(studentMarks, rolls);
  for (int i = 0; i < percentages.size();) {
    cout << percentages.at(i) << endl;

    i = i + 1;
    if (!(i < percentages.size())) {
    }
  };
  return 1;
}
