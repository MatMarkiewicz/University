#include <iostream>

using namespace std;

int main()
{
    int n;
    long long a,b;
    scanf("%d %lld %lld",&n,&a,&b);
    long long int arr[n];
    for (int i = 0;i<n;i++){
        scanf("%lld",&arr[i]);
    }
    long long int msf = arr[0];
    long long int meh = arr[0];
    long long int mieh = arr[0];
    long long int misf = arr[0];
    long long int res;
    for (int i = 1;i<n;i++){
        meh += arr[i];
        mieh += arr[i];
        if (meh < arr[i]) meh = arr[i];
        if (mieh > arr[i]) mieh = arr[i];
        if (msf < meh) msf = meh;
        if (misf > mieh) misf = mieh;
    }
    if (a>0) {
        res = msf * a +b;
    }else{
        res = misf * a + b;
    }
    printf("%lld",res);
    return 0;
}
