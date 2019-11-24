#include <bits/stdc++.h>

using namespace std;

#define N 100010
vector <int> G[N];

vector < pair <int,int> > res;

void DFS(int i,int parent,int start){
    if (G[i].size() == 1 && i != start ) res.push_back({start,i});
    for (auto a: G[i]){
        if (a!=parent) DFS(a,i,start);
    }
}

int main()
{
    int n,a,b;
    cin >> n;
    for (int i =0; i<n-1; i++){
        cin >> a >> b;
        G[a].push_back(b);
        G[b].push_back(a);
    }
    int maxd = 0;
    int start = 0;
    bool f = 0;
    int d;
    for (int i = 1;i<=n;i++){
        d = G[i].size();
        if (f && d > 2){
            cout << "No\n";
            return 0;
        }
        if (d>2) f = 1;
        if (d>maxd){
            maxd=d;
            start=i;
        }
    }
    cout << "Yes\n";
    DFS(start,0,start);
    cout << res.size() << "\n";
    for (auto a:res){
        cout << a.first << " " << a.second << "\n";
    }
    return 0;
}
