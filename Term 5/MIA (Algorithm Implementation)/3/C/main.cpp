#include <bits/stdc++.h>

using namespace std;

#define N 1010
const long long Inf = 1e17;

int n,m,x,y,u,v,w;
int t[N];
int c[N];
vector < pair <int,int> > G[N];
long long Dists[N][N];
priority_queue< pair <long long,int>, vector < pair <long long,int> >, greater < pair <long long,int> > > pq;

void Dijkstra(int start){
    for (int i=0;i<n;i++){
        Dists[start][i] = Inf;
    }
    Dists[start][start] = 0;
    pq.push({0,start});
    while (!pq.empty()){
        pair <long long,int> top_v = pq.top();
        pq.pop();
        if (top_v.first != Dists[start][top_v.second]) continue;
        for (auto a:G[top_v.second]){
            if (top_v.first + a.second < Dists[start][a.first]){
                Dists[start][a.first] = top_v.first + a.second;
                pq.push({top_v.first + a.second,a.first});
            }
        }
    }
}

int main()
{
    scanf("%d %d",&n,&m);
    scanf("%d %d",&x,&y);
    for (int i=0;i<m;i++){
        scanf("%d %d %d",&u,&v,&w);
        G[u-1].push_back({v-1,w});
        G[v-1].push_back({u-1,w});
    }
    for (int i=0;i<n;i++){
        scanf("%d %d",&t[i],&c[i]);
    }
    for (int i=0;i<n;i++){
        Dijkstra(i);
    }
    for (int i=0;i<n;i++){
        G[i].clear();
    }
    for (int i=0;i<n;i++){
        for (int j=0;j<n;j++){
            if (Dists[i][j] <= t[i]){
                G[i].push_back({j,c[i]});
            }
        }
    }
    x--;
    y--;
    Dijkstra(x);
    if (Dists[x][y] < Inf){
        cout << Dists[x][y] << endl;
    }
    else{
        cout << -1 << endl;
    }
    return 0;
}
