#include <bits/stdc++.h>

using namespace std;

#define N 80010
vector <int> G[N];
long long n,res;
long long S[N];

void DFS(int i,int parent){
    long long t = 0;
    S[i] = 1;
    for (auto a: G[i]){
        if (a != parent){
            DFS(a,i);
            t += S[i] * S[a];
            S[i] += S[a];
        }
    }
    res -= t*t;
    res -= 2*t*S[i]*(n-S[i]);
    return;
}

int main()
{
    cin >> n;
    int a,b;
    for (int i =0; i<n-1; i++){
        cin >> a >> b;
        G[a].push_back(b);
        G[b].push_back(a);
    }
    res = 1ll * n * (n-1) / 2;
    res = res * res;
    DFS(1,0);
    cout << res << endl;
    return 0;
}
