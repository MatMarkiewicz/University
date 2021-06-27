using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Threading; 
using Solution;
using System;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestStandardSingleton()
        {
            StandardSingleton s1 = StandardSingleton.Instance();
            StandardSingleton s2 = StandardSingleton.Instance();
            Assert.AreSame(s1,s2);
            Assert.IsNotNull(s1);
        }

        [TestMethod]
        public void TestThreadSingleton()
        {
            ThreadSingleton s1 = ThreadSingleton.Instance();
            ThreadSingleton s2 = ThreadSingleton.Instance();
            Assert.AreSame(s1,s2);
            Assert.IsNotNull(s1);
        }

        [TestMethod]
        public void TestTimeSingleton()
        {
            TimeSingleton s1 = TimeSingleton.Instance();
            TimeSingleton s2 = TimeSingleton.Instance();
            Assert.AreSame(s1,s2);
            Assert.IsNotNull(s1);
        }

        [TestMethod]
        public void TestThreadSingletonConcurrently()
        {
            ThreadSingleton s1=null, s2=null;
            Thread t1 = new Thread(() => 
            {
                s1 = ThreadSingleton.Instance();
            });

            Thread t2 = new Thread(() => 
            {
                s2 = ThreadSingleton.Instance();
            });

            t1.Start();
            t2.Start();
            t1.Join();
            t2.Join();

            Assert.IsNotNull(s1);
            Assert.IsNotNull(s2);
            Assert.AreNotSame(s1,s2);
        }

        [TestMethod]
        public void TestTimeSingletonWithDelay()
        {
            TimeSingleton s1 = TimeSingleton.Instance();
            Thread.Sleep(TimeSpan.FromSeconds(4));
            TimeSingleton s2 = TimeSingleton.Instance();
            Assert.AreSame(s1,s2);
            Assert.IsNotNull(s1);
        }

        [TestMethod]
        public void TestTimeSingletonWithDelay2()
        {
            TimeSingleton s1 = TimeSingleton.Instance();
            Thread.Sleep(TimeSpan.FromSeconds(6));
            TimeSingleton s2 = TimeSingleton.Instance();
            Assert.AreNotSame(s1,s2);
            Assert.IsNotNull(s1);
            Assert.IsNotNull(s2);
        }


    }
}
