#include<bits/stdc++.h>
using namespace std;

int main()
{
    long long int n,m,k;
    cin >> n >> m >> k;
    long long int l=1;
    long long int r=n*m;
    long long int mid,c;
    while (l<r){
        mid = (l+r)/2;
        c = 0;
        for (long long int i=1;i<=n;i++){
            c += min(mid/i,m);
        }
        if (c<k){
            l = mid+1;
        }else{
            r = mid;
        }
    }
    cout << l << endl;
    return 0;
}
