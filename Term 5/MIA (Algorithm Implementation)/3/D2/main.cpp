#include <iostream>
#include <cstdio>
#include <vector>

#define MAX 100005
#define LOGN 16

using namespace std;

vector< vector <int> > V;
int level[MAX];
vector< pair <int,int> > inpt;
bool vis[MAX];
long long int paths[MAX];

int n, from, to, counter=0, k, a, b, l;

struct LCA {
    vector<int> height, euler, first, segtree;
    vector<bool> visited;
    int n;

    LCA(vector<vector<int>> &adj, int root = 0) {
        n = adj.size();
        height.resize(n);
        first.resize(n);
        euler.reserve(n * 2);
        visited.assign(n, false);
        dfs(adj, root);
        int m = euler.size();
        segtree.resize(m * 4);
        build(1, 0, m - 1);
    }

    void dfs(vector<vector<int>> &adj, int node, int h = 0) {
        visited[node] = true;
        height[node] = h;
        first[node] = euler.size();
        euler.push_back(node);
        for (auto to : adj[node]) {
            if (!visited[to]) {
                dfs(adj, to, h + 1);
                euler.push_back(node);
            }
        }
    }

    void build(int node, int b, int e) {
        if (b == e) {
            segtree[node] = euler[b];
        } else {
            int mid = (b + e) / 2;
            build(node << 1, b, mid);
            build(node << 1 | 1, mid + 1, e);
            int l = segtree[node << 1], r = segtree[node << 1 | 1];
            segtree[node] = (height[l] < height[r]) ? l : r;
        }
    }

    int query(int node, int b, int e, int L, int R) {
        if (b > R || e < L)
            return -1;
        if (b >= L && e <= R)
            return segtree[node];
        int mid = (b + e) >> 1;

        int left = query(node << 1, b, mid, L, R);
        int right = query(node << 1 | 1, mid + 1, e, L, R);
        if (left == -1) return right;
        if (right == -1) return left;
        return height[left] < height[right] ? left : right;
    }

    int lca(int u, int v) {
        int left = first[u], right = first[v];
        if (left > right)
            swap(left, right);
        return query(1, 0, euler.size() - 1, left, right);
    }
};

long long int dfs2(int v,int lvl)
{
    level[v] = lvl;
    long long int s = paths[v];
	for(auto i:V[v]){
		if(!vis[i]) {
			vis[i]=true;
			s+= dfs2(i,lvl+1);
		}
	}
	paths[v] = s;
	return s;
}

int main()
{
	scanf("%d", &n);
	V.resize(n+1,vector <int> (0));
	for(int i = 0; i < n-1; ++i) {
		scanf("%d %d", &from, &to);
		V[from].push_back(to);
		V[to].push_back(from);
		inpt.push_back(make_pair(from,to));
		paths[i] =0;
		vis[i]=false;
	}
	paths[n-1] = 0;
	paths[n] = 0;
	vis[n-1] = false;
	vis[n] = false;

	struct LCA L(V,1);

    scanf("%d",&k);
    for (int i=0;i<k;i++){
        scanf("%d %d",&a,&b);
        l = L.lca(a,b);
        paths[a]++;
        paths[l]--;
        paths[l]--;
        paths[b]++;
    }

    vis[1] = true;
    dfs2(1,1);

    for(auto i:inpt){
        if (level[i.first] > level[i.second]){
            printf("%lld ",paths[i.first]);
        }
        else{
            printf("%lld ",paths[i.second]);
        }
	}

	return 0;
}
