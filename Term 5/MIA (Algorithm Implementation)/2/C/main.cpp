#include <iostream>
#include <algorithm>
#include <bits/stdc++.h>

using namespace std;


int main()
{
    int n;
    scanf("%d",&n);
    set <long long int> s1;
    set <long long int> s2;
    set <long long int> s3;
    long long int el;
    long long int new_el;
    for (int i = 0;i<n;i++){
        scanf(" %lld",&el);
        s3.clear();
        set<long long int>::iterator it = s2.begin();
        for (;it != s2.end();it++){
            new_el = __gcd(*it,el);
            s3.insert(new_el);
            s1.insert(new_el);
        }
        s3.insert(el);
        s1.insert(el);
        s2 = s3;
    }
    printf("%d",s1.size());
    return 0;
}
