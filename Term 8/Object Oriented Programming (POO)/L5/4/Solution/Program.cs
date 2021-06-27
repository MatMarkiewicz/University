using System;
using System.Collections;

namespace Solution
{

    class CompatisonComparerAdapter<T> : IComparer{
        private readonly Comparison<T> _comparison;

        public CompatisonComparerAdapter(Comparison<T> comparison){
            _comparison = comparison;
        }

        public int Compare(object x, object y){
            return _comparison((T)x, (T)y);
        }
    }

    class Program
    {

        static int IntComparer(int x, int y)
        {
            return x.CompareTo(y);
        }

        static void Main(string[] args)
        {
            ArrayList a = new ArrayList() { 1, 5, 3, 3, 2, 4, 3 };
            IComparer compatisonComparerAdapter = new CompatisonComparerAdapter<int>(IntComparer);
            a.Sort(compatisonComparerAdapter);
            foreach (var v in a){
                Console.WriteLine("{0}", v);
            }
        }
    }
}
