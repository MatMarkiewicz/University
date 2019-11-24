#include <iostream>

using namespace std;

long long int modmult(long long a, long long b, long long mod){
    long long x = 0;
    long long y = a % mod;
    while (b>0){
        if (b&1){
            x = (x+y) % mod;
        }
        y = (2 * y) % mod;
        b /= 2;
    }
    return x % mod;
}

long long int modpow(long long int base, long long int exp, long long int mod) {
  long long int res = 1;
  while (exp > 0) {
    if (exp & 1){
        res = modmult(res,base,mod);
    }
    base = modmult(base,base,mod);
    exp >>= 1;
  }
  return res;
}

int main()
{
    int t;
    scanf("%d",&t);
    for(int i = 0;i<t;i++){
        long long int n,k,m;
        scanf("%lld %lld %lld",&n,&k,&m);
        long long int res = modpow(k,n,m);
        printf("%lld\n",res);
    }
}

