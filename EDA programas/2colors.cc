#include <iostream>
#include <vector>
#include <queue>

using namespace std;

typedef vector< vector<int> > graph; //undirected graph (adjacencies)

bool two_color(const graph& g) {
	int n = g.size();
	vector<int> color(n, -1);
	queue< pair<int,int> > q;
	for (int i = 0; i < g.size(); ++i) {
		if (color[i] < 0) {
			color[i] = 1;
			q.push(make_pair(i, 1));
			while (not q.empty()) {
				int u = q.front().first;
				int c = q.front().second;
				q.pop();
				for (int j = 0; j < g[u].size(); ++j) {
					int v = g[u][j];
					if (color[v] < 0) {
						q.push(make_pair(v, color[u]));
						color[v] = 1 - color[u];
					}
					else if (color[v] == color[u]) return false;
				}
			}
		}
	}
	return true;
}

int main() {
	int n, m;
	while (cin >> n >> m) {
		graph g(n);
		for (int i = 0; i < m; ++i) {
			int x, y;
			cin >> x >> y;
			g[x].push_back(y);
			g[y].push_back(x);
		}
		cout << (two_color(g) ? "yes" : "no") << endl;
	}
}
