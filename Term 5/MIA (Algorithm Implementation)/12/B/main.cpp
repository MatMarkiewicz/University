#include <bits/stdc++.h>

using namespace std;

typedef complex<double> cd;
const double PI = acos(-1);
const int MOD = 1009;

int reverse(int num, int l){
	int res = 0;
	for(int i=0;i<l;i++){
		if(num&(1<<i))
			res |= 1<<(l-1-i);
	}
	return res;
}

void fft(vector<cd> &a, bool invert){
	int n = a.size();
	int lg_n = 0;
	while ((1 << lg_n) < n)
        lg_n++;

	for(int i=0;i<n;i++){
		if(i < reverse(i,lg_n)) swap(a[i], a[reverse(i,lg_n)]);
	}

	for(int len = 2; len<=n; len<<=1){
		double ang = 2*PI/len*(invert ? -1 : 1);
		complex<double> wl(cos(ang),sin(ang));
		for(int i = 0; i < n; i+=len){
			complex<double> w(1);
			for(int j = 0; j < len/2; ++j){
				complex<double> u = a[i+j], v = a[i+j+len/2] * w;
				a[i + j] = u + v;
				a[i + j + len/2] = u - v;
				w *= wl;
			}
		}
	}

	if(invert) for(int i = 0; i < n; ++i){
		a[i] /= n;
	}
}

void mult(vector<cd> &a, vector<cd> &b) {
    int n = 1;
    int s = a.size() + b.size() - 1;
    while (n < s)
        n <<= 1;
    a.resize(n);
    b.resize(n);

    fft(a, false);
    fft(b, false);

    for (int i = 0; i < n; i++)
        a[i] *= b[i];

    fft(a, true);

    a.resize(s);
    for (int i = 0; i < s; i++)
        a[i] = (long long) round(a[i].real()) % MOD;
}


int main()
{
    ios_base::sync_with_stdio(false);
	cin.tie(NULL);
    int n,m,k;
    cin >> n >> m >> k;
    int A[m] = {0};
    int a;
    for (int i=0;i<n;i++){
        cin >> a;
        A[a-1]++;
    }

    priority_queue<pair<int,int>> pq;
    for (int i=0;i<m;i++){
        pq.push({-A[i],i});
    }

    vector<cd> P[m];
    for (int i=0;i<m;i++){
        P[i].resize(A[i]+1,1);
    }

    int pa,pb,d;
    while (pq.size() > 1){
        pa = pq.top().second;
        d = pq.top().first;
        pq.pop();
        pb = pq.top().second;
        d += pq.top().first;
        pq.pop();
        mult(P[pa],P[pb]);
        pq.push({d,pa});
    }

    cout << round(P[pq.top().second][k].real()) << endl;

    return 0;
}

