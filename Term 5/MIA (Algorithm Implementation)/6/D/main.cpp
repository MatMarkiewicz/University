#include <iostream>

using namespace std;

#define ll long long
const int M = 100005;
const int N = 105;
ll DP[N][2*M];
ll A[N];
ll B[N];
int main()
{
    ll n,k,a,b;
    scanf("%lld %lld",&n,&k);
    for (int i=1;i<=n;i++){
        scanf("%lld",&A[i]);
    }
    for (int i=1;i<=n;i++){
        scanf("%lld",&B[i]);
    }
    DP[1][k*B[1] - A[1] + M] = A[1];
    for (int i=2;i<=n;i++){
        for (int j=5;j<=200005;j++){
            if (DP[i-1][j]){
                DP[i][j] = max(DP[i][j],DP[i-1][j]);
                a = DP[i-1][j];
                b = (a +j-M)/k;
                a += A[i];
                b += B[i];
                DP[i][k*b - a+M] = max(DP[i][k*b - a+M],a);
            }
        }
        DP[i][k*B[i]-A[i]+M] = max(DP[i][k*B[i]-A[i]+M],A[i]);
    }

    if(DP[n][M]){
        printf("%lld\n",DP[n][M]);
    }else{
        printf("%d\n",-1);
    }
    return 0;
}
