using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Solution;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            ArrayList a = new ArrayList() { 1, 5, 3, 3, 2, 4, 3 };
            IComparer compatisonComparerAdapter = new CompatisonComparerAdapter<int>(IntComparer);
            a.Sort(compatisonComparerAdapter);
            int prev = -1000000;
            foreach (var v in a){
                Assert.IsTrue(prev <= v);
                prev = v;
            }
        }

        [TestMethod]
        public void TestMethod2()
        {
            ArrayList a = new ArrayList() { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2};
            IComparer compatisonComparerAdapter = new CompatisonComparerAdapter<int>(IntComparer);
            a.Sort(compatisonComparerAdapter);
            int prev = -1000000;
            foreach (var v in a){
                Assert.IsTrue(prev <= v);
                prev = v;
            }
        }
    }
}
