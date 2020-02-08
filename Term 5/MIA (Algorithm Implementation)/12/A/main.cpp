#include <bits/stdc++.h>

using namespace std;

typedef complex<double> cd;
const double PI = acos(-1);

void fft(vector<cd> & a, bool invert) {
    int n = a.size();
    if (n == 1) return;

    vector<cd> a0(n / 2), a1(n / 2);
    for (int i = 0; 2 * i < n; i++) {
        a0[i] = a[2*i];
        a1[i] = a[2*i+1];
    }

    fft(a0, invert);
    fft(a1, invert);

    double alpha;
    if (invert)
        alpha = -2 * PI / n;
    else
        alpha = 2 * PI / n;
    cd w(1);
    cd wn(cos(alpha), sin(alpha));

    for (int i = 0; 2*i<n; i++) {
        a[i] = a0[i] + w*a1[i];
        a[i + n/2] = a0[i] - w*a1[i];
        if (invert) {
            a[i] /= 2;
            a[i + n/2] /= 2;
        }
        w *= wn;
    }
}

vector<long long int> mult(vector<long long int> const& a, vector<long long int> const& b) {
    vector<cd> fa(a.begin(), a.end()), fb(b.begin(), b.end());
    int n = 1;
    while (n < a.size() + b.size())
        n <<= 1;
    fa.resize(n);
    fb.resize(n);

    fft(fa, false);
    fft(fb, false);

    for (int i = 0; i < n; i++)
        fa[i] *= fb[i];

    fft(fa, true);

    vector<long long int> result(n);
    for (int i = 0; i < n; i++)
        result[i] = round(fa[i].real());
    return result;
}

int main()
{
    int T;
    long long int n,a0,b0;
    cin >> T;
    for (int t=0; t<T; t++){
        cin >> n;
        vector<long long int> a;
        vector<long long int> b;
        for (int i=0;i<=n;i++){
            cin >> a0;
            a.push_back(a0);
        }
        for (int i=0;i<=n;i++){
            cin >> b0;
            b.push_back(b0);
        }
        vector<long long int> c = mult(a,b);
        for (int i=0;i<2*n+1;i++){
            cout << c[i] << " ";
        }
        cout << endl;
    }
    return 0;
}
