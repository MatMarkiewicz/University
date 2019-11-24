#include <bits/stdc++.h>
using namespace std;

void imp() {
  cout << "Impossible\n";
  exit(0);
}

#define ll long long

ll invtriange(ll x) {
  ll l = 1, r = 1000000;
  while (r - l > 1) {
    ll m = (l + r) / 2;
    if (m * (m - 1) / 2 > x) r = m;
    else l = m;
  }
  if (l * (l - 1) / 2 != x) {
    imp();
  }
  return l;
}

int main() {
  ll c0 = invtriange(0);
  ll c1 = invtriange(45);
  cout << c0 << endl;
  cout << c1 << endl;
  return 0;
}
