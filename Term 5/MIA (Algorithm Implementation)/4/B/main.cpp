#include <bits/stdc++.h>

using namespace std;

#define N 100010
vector <int> G[N];
bool init[N];
bool goal[N];
vector <int> res;
void DFS(int i,int parent,int zp,int znp,int odd){
    if ((odd && znp) || (!odd && zp)){
        init[i] = !init[i];
    }
    if (init[i] != goal[i]){
        res.push_back(i);
        if (odd){
            znp++;
            znp%=2;
        }
        else{
            zp++;
            zp%=2;
        }
    }
    for (auto a: G[i]){
        if (a != parent) DFS(a,i,zp,znp,1-odd);
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
    for (int i = 1;i<=n;i++){
        cin >> init[i];
    }
    for (int i = 1;i<=n;i++){
        cin >> goal[i];
    }
    DFS(1,-1,0,0,0);
    printf("%d\n",res.size());
    for (auto a: res){
        printf("%d\n",a);
    }
    return 0;
}
