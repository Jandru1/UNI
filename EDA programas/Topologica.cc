#include <iostream>
#include <string>
#include <vector>
#include <queue>
#include <list>
#include <map>

using namespace std;

typedef vector< vector<int> > graph;

void topological_sorting(graph &adj, vector<int> &indegree, vector<string> &s, map<string, int> &M) {
	priority_queue< string, vector<string>, greater<string> > q;
	for (int i = 0; i < adj.size(); ++i) {
		if (indegree[i] == 0) q.push(s[i]);
	}

	list<string> l;
	while (not q.empty()) {
		int u = M[q.top()]; q.pop();
		l.push_back(s[u]);
		for (int i = 0; i < adj[u].size(); ++i) {
			int k = adj[u][i];
			if (--indegree[k] == 0) q.push(s[k]);
		}
	}

	if (l.size() == s.size()) {
		list<string>::iterator it;
		for (it = l.begin(); it != l.end(); ++it) cout << *it;
	}
	 else cout << "NO VALID ORDERING";
	cout << endl;
}

int main() {
	int n;
	while (cin >> n) {
		map<string, int> M;
		vector<string> s(n);

		for (int i = 0; i < n; ++i) {
			cin >> s[i];
			M[s[i]] = i; //M.insert(make_pair(s[i]), i);
		}

		int m;
		cin >> m;

		graph adj(n);
		vector<int> indegree(n, 0);
//indegree: numero de dependencias
//adj: vertice con sus adyacencias
//M: paraula amb el ordre en que ens la dona
//s: vector con las palabras
		for (int i = 0; i < m; ++i) {
			string s1, s2;
			cin >> s1 >> s2;
			adj[M[s1]].push_back(M[s2]);
			++indegree[M[s2]];
		}
		topological_sorting(adj, indegree, s, M);
	}
}
