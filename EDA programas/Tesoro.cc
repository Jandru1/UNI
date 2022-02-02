#include <iostream>
#include <vector>
#include <queue>

using namespace std;

template<typename T>
using Matrix = vector<vector<T>>;

struct Position {
    int r, c, d;
    Position(int r, int c, int d) {
        this->r = r;
        this->c = c;
        this->d = d;
    }
};

/** \pre m[0].size() > 0 */
void readMatrix(Matrix<char>& m) {
    for (int i = 0; i < m.size(); ++i) {
        for (int j = 0; j < m[i].size(); ++j)
            cin >> m[i][j];
    }
}

bool posValida(const Position& p, Matrix<char>& m, Matrix<bool>& v) {
    return p.r >= 0 and p.r < m.size() and p.c >= 0 and p.c < m[p.r].size() and not v[p.r][p.c] and m[p.r][p.c] != 'X';
}

int distTreasure(Matrix<char>& map, Matrix<bool>& encolados, const Position& start) {
    queue<Position> Q;
    Q.push(start);
    encolados[start.r][start.c] = true;
    while (not Q.empty()) {
        Position p = Q.front();
        Q.pop();
        if (map[p.r][p.c] == 't')
            return p.d;
        Position up(p.r - 1, p.c, p.d + 1);
        if (posValida(up, map, encolados)) {
            Q.push(up);
            encolados[up.r][up.c] = true;
        }
        Position down(p.r + 1, p.c, p.d + 1);
        if (posValida(down, map, encolados)) {
            Q.push(down);
            encolados[down.r][down.c] = true;
        }
        Position left(p.r, p.c - 1, p.d + 1);
        if (posValida(left, map, encolados)) {
            Q.push(left);
            encolados[left.r][left.c] = true;
        }
        Position right(p.r, p.c + 1, p.d + 1);
        if (posValida(right, map, encolados)) {
            Q.push(right);
            encolados[right.r][right.c] = true;
        }
    }
    return -1;
}

int main() {
    int n, m;
    cin >> n >> m;
    Matrix<char> map(n, vector<char>(m));
    Matrix<bool> visitados(n, vector<bool>(m, false));
    readMatrix(map);
    Position start(0, 0, 0);
    cin >> start.r >> start.c;
    start.r--; // Start on [1][1]
    start.c--; // Start on [1][1]
    int d = distTreasure(map, visitados, start);
    if (d >= 0)
        cout << "minimum distance: " << d << endl;
    else
        cout << "no treasure can be reached" << endl;
}
