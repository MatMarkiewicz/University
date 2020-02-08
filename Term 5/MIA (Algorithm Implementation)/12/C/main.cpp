#include <bits/stdc++.h>

using namespace std;


typedef complex<double> cd;
const double PI = acos(-1);

int T, n, m, si, ln, r[1100000], ta;
cd x[1100000], y[1100000], w, wn, tx, ty;
char STRING[500005];
vector< int > ans;
bool o;


void fft(cd *a, bool invert) {
    for (int i = 0; i < si; i++)
		if (i < r[i])
			swap(a[i], a[r[i]]);
	for (int i = 0; i < ln; i++) {
		wn = complex< double >(cos(PI / (1 << i)), ((invert)?-1:1) * sin(PI / (1 << i)));
		for (int j = 0; j < si; j += 1 << (i + 1)) {
			w = 1;
			for (int k = 0; k < 1 << i; k++) {
				tx = a[j + k];
				ty = w * a[(1 << i) + j + k];
				a[j + k] = tx + ty;
				a[(1 << i) + j + k] = tx - ty;
				w *= wn;
			}
		}
	}
}

int main()
{
    scanf("%d", &T);
    for (int t=0;t<T;t++){
        scanf("%d%s", &n, STRING);
        m=n,si=1,ln=0;
        while (si <= n+m){
            si *= 2;
            ln++;
        }
        memset(x, 0, 16 * si);
		memset(y, 0, 16 * si);
        for (int i = 0; i < n; i++) {
			x[i] = STRING[i] == 'V';
			y[n - 1 - i] = STRING[i] == 'K';
		}
		for (int i = 0; i < si; i++){
			r[i] = (i & 1) ? r[i / 2] / 2 | si / 2 : r[i / 2] / 2;
		}
		fft(x,false);
		fft(y,false);
		for (int i = 0; i < si; i++)
			x[i] *= y[i];
        fft(x,true);
        ans.clear();
        for (int i = 1; i <= n; i++) {
			o = 1;
			for (int j = i; j < n && o; j += i)
				if (x[n - 1 + j].real() / si > 0.5 || x[n - 1 - j].real() / si > 0.5)
					o = 0;
			if (o)
				ans.push_back(i);
		}
		printf("%d\n", ans.size());
		for (int i = 0; i < ans.size(); i++)
			printf("%d%c", ans[i], i == ans.size() - 1 ? '\n' : ' ');

    }
    return 0;
}
