#include <bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef vector <int> vi;
typedef vector <ll> vl;
typedef pair <int, int> pi;
typedef pair <ll, ll> pl;
typedef tuple <int, int, int> ti;
typedef vector < pl > vpl;
typedef vector < pi > vpi;
typedef vector < ti > vti;

//double t = clock();
//cout << (clock() - t) / CLOCKS_PER_SEC <<endl;
bool debug = false;
#define deb if(debug)
#define pb push_back
#define FOR(i,x,n) for(int i = x; i < n; i++)
#define SIZE (3 * 1e5 + 42)
#define MAX (1000000 + 42)
#define MOD (1000000000 + 9)
#define DRZ (2<<21)
#define PI 3.14159265


vpl G[ int(SIZE) ];
ll dist[ int(SIZE) ], ancestor[ int(SIZE) ];
set < pi > BAD;

void Dijkstra(int n)
{
  FOR(i, 0, n + 1)
  {
    dist[ i ] = 1e18;
  }

  dist[ 1 ] = 0;
  priority_queue < pair< ll, int > > Q;
  Q.push({0, 1});

  while(!Q.empty())
  {
    int act_node = Q.top().second;
    ll act_distance = -Q.top().first;
    Q.pop();

    for(auto w: G[ act_node ])
    {
      ll new_dist = act_distance + w.second;
      if(dist[w.first] > new_dist)
      {
        dist[w.first] = new_dist;
        Q.push({-new_dist, w.first});
        ancestor[w.first] = act_node;
      }
    }
  }

  FOR(i, 0, n)
  {
    for(auto w: G[i])
    {
      if(ancestor[i] == w.first)
      {
        //cout << i << " -> " << w.first << endl;
        BAD.insert({i, w.first});
        break;
      }
    }
  }

  // FOR(i, 0, n)
  // {
  //   cout << i << " -> " << dist[ i ] << endl;
  // }

}


void solve(int n)
{
  FOR(i, 0, n + 1)
  {
    dist[ i ] = 1e18;
    ancestor[ i ] = -1;
  }

  dist[ 0 ] = 0;
  priority_queue < pair< ll, int > > Q;
  Q.push({0, 0});

  while(!Q.empty())
  {
    int act_node = Q.top().second;
    ll act_distance = -Q.top().first;
    Q.pop();

    for(auto w: G[ act_node ])
    {
      ll new_dist = act_distance + w.second;
      auto it = BAD.find({act_node, w.first});
      if(dist[w.first] > new_dist and it == BAD.end())
      {
        dist[w.first] = new_dist;
        Q.push({-new_dist, w.first});
        ancestor[w.first] = act_node;
      }
    }
  }
  if(dist[1] == 1e18)
  {
    cout << "impossible\n";
    return;
  }

  int goal = 1;
  vi answer;
  while( goal != 0 )
  {
     answer.push_back(goal);
     goal = ancestor[ goal ];
  }
  answer.pb(0);
  reverse(answer.begin(), answer.end());
  cout << answer.size() << " ";
  for(auto a: answer)
  {
    cout << a << " ";
  }
  cout << endl;
}

int main()
{
    ios_base::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);

    int n, m;
    cin >> n >> m;

    FOR(i, 0, m)
    {
      int a, b, c;
      cin >> a >> b >> c;
      G[a].pb({b, c});
      G[b].pb({a, c});
    }

    Dijkstra(n);
    solve(n);

    return 0;
}
