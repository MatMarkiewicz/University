#include <iostream>
#include <cstdio>
#include <vector>

#define MAX 100005
#define LOGN 16

using namespace std;

vector<int> V[MAX];
int P[LOGN][MAX], pre[MAX], treeSize[MAX];
int level[MAX];
vector< pair <int,int> > inpt;
bool vis[MAX];

long long int paths[MAX];

int n, from, to, counter=0, k, a, b, l;

bool children(int u, int v)
{
	return (pre[u]>=pre[v] && pre[u] < pre[v]+treeSize[v]);
}

int lca(int u, int v)
{
	if(children(u, v)) return v;
	if(children(v, u))return u;

	int i=u, j=LOGN-1;
	while(j>=0) {
		if(children(v, P[j][i]))
			j--;
		else
			i = P[j][i];
	}

	return P[0][i];
}

void dfs(int v)
{
	counter++;
	pre[v]=counter;
	for(auto i:V[v]){
		if(!vis[i]) {
			P[0][i]=v;
			vis[i]=true;
			dfs(i);
		}
	}
	treeSize[v]=counter+1-pre[v];
}

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
	for(int i = 0; i < n-1; ++i) {
		scanf("%d %d", &from, &to);
		V[from].push_back(to);
		V[to].push_back(from);
		inpt.push_back(make_pair(from,to));
	}
	for(int i = 0; i <= n; i++) {
		pre[i]=0;
		paths[i] =0;
		treeSize[i]=0;
		vis[i]=false;
	}
    for(int i = 0; i < LOGN; i++){
        for(int j = 0; j < MAX; j++){
            P[i][j]=0;
        }
    }
	vis[1]=true;
	dfs(1);

	P[0][1]=1;
	for(int i = 1; i < LOGN; i++){
		for(int j = 1; j < MAX; j++){
			P[i][j]=P[i-1][P[i-1][j]];
			vis[i] = false;
		}
	}

    scanf("%d",&k);
    for (int i=0;i<k;i++){
        scanf("%d %d",&a,&b);
        l = lca(a,b);
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
