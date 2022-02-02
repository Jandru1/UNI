#include <iostream>
#include <vector>
#include <string>

using namespace std;

void backtraking(int i, int n, vector<string> &permutation, const vector<string> &words, vector<bool> &marked) {
  if (i == n) {
    for (int j = 0; j < n; ++j) cout << (j ? ',' : '(') << permutation[j];
    cout << ')' << endl;
  }
  else {
    for (int j = 0; j < n; ++j) {
      if (not marked[j]) {
        marked[j] = true;
        permutation[i] = words[j];
        backtraking(i+1, n, permutation, words, marked);
        marked[j] = false;
      }
    }
  }
}

int main() {
  int n;
  cin >> n;
  vector<string> permutation(n), words(n);
  for (int i = 0; i < n; ++i)
    cin >> words[i];
  vector<bool> marked(n, false);
  backtraking(0, n, permutation, words, marked);
}
