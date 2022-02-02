#include <iostream>
#include <vector>
#include <queue>
using namespace std;

typedef vector<vector<char> > Matrix;
typedef vector<vector<char> > Visitades;

struct pos {
  int i;
  int j;
  int dist;
}

void read_matrix (matrix &m, int f, int c) {
    for (int i = 0; i < f; ++i) {
        for (int j = 0; j < c; ++j)
            cin >> m[i][j];
    }
}


}
bool posicio_valida(pair <int,int> pos, Matrix &m, Visitades &v){
  //si pos es X, se pasa del limite o ya la he visitado devuelvo FALSE
  if (pos.first < 0 or pos.first > i or pos.second < 0 or pos.second > j) return false;
  else if (m[pos] == 'X') return false;
}

int bfs(const Matrix &m, int i_ini, int j_ini, int f, int c) {
  Visitades visitades (f, vector<int> (c, 0)) //matriu de boleans que et diu si has visitat la posicio o no.
  queue< pair<int,int> > q;
  q.push(make_pair(i_ini, j_ini));
  while(!q.empty()) {
    pair<int,int> pos = q.first();
    q.pop();
    if(m[pos.i][pos.j] == 't') reutrn pos.d;
    else {
      int i_nord = pos.first -1;
      int j_nord = pos.second;
      int d_nord = pos.dist +1 //CAMBIAR ESTO
      pair<int,int> nord(i_nord, j_nord);
      if(posicio_valida(nord, m, v)) q.push(nord);

      int i_sud = pos.first +1;
      int j_sud = pos.second;
      pair<int,int> nord(i_sud, j_sud);
      if(posicio_valida(sud, m, v)) q.push(nord);

      int i_est = pos.first;
      int j_est = pos.second +1;
      pair<int,int> nord(i_est, j_est);
      if(posicio_valida(est, m, v)) q.push(nord);


      int i_oest = pos.first;
      int j_oest = pos.second -1;
      pair<int,int> nord(i_oest, j_oest);
      if(posicio_valida(oest, m, v)) q.push(nord);
    }
  }
}
int main() {
  int f, c, i_ini, j_ini;
  cin >> f >> c;
  Matrix m;
  read_matrix(m, f, c);
  cin >> i_ini >> j_ini;
  int res = bfs(G, i_ini, j_ini, f, c);
  if (res < 0) cout << "no es pot arribar a cap tresor" << endl;
  else cout << "distancia minima: " << res << endl;
}
