#include <iostream>

using namespace std;
typedef long long int ll;
ll dist(int i, int j, int n, ll sums[])
{
    ll distij = abs(sums[j] - sums[i]);
    return min(distij, (sums[n] - distij));
}

int main()
{
    int n;
    scanf("%d",&n);
    ll sums[n+1];
    ll temp;
    sums[0] = 0;
    for(int i=1;i<n+1;i++)
    {
        scanf("%lld",&temp);
        sums[i] = sums[i-1] + temp;
    }
    int i=0;
    int j=0;
    ll max0 = 0;
    while(max0<=dist(i,j+1,n,sums))
    {
        max0 = dist(i,j+1,n,sums);
        ++j;
    }
    i = n-1;
    while(j>0)
    {
        ll max1 = dist(i,j,n,sums);
        while (max1<=dist(i,j-1,n,sums))
        {
            max1 = dist(i,j-1,n,sums);
            --j;
        }
        max0 = max(max0,max1);
        --i;
    }
    printf("%lld",max0);
    return 0;
}
