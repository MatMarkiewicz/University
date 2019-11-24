#include<bits/stdc++.h>

using namespace std;

#define ll long long
const int N = 5003;

ll DP[N][N];
ll sum[N];


int main()
{
    ll n,m,k;
    scanf("%lld %lld %lld",&n,&m,&k);
    sum[0] = 0;
    ll a;
    for (int i=1;i<=n;i++){
        scanf("%lld",&a);
        sum[i] = sum[i-1] + a;
    }
    for (int i=1;i<=n;i++){
        for (int j=0;j<=n;j++){
            if (i*m > j) DP[i][j] = 0;
            else DP[i][j] = max(DP[i][j-1], DP[i-1][j-m] + sum[j] - sum[j-m]);
        }
    }
    printf("%lld\n",DP[k][n]);
    return 0;
}
