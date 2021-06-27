using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DI_engine;

namespace DI_Tests
{
    [TestClass]
    public class UnitTest1
    {

        public interface IFoo{}
        public class Foo :IFoo{}
        public class Bar :IFoo{}
        public class Quz{}
        public interface IQuz{}
        public class Baz{
            public Baz(int a){}
        }
        public abstract class Qug :IQuz{}

        [TestMethod]
        public void TestSingleton(){
            SimpleContainer c = new SimpleContainer();

            c.RegisterType<Foo>( true );
            Foo f1 = c.Resolve<Foo>();
            Foo f2 = c.Resolve<Foo>();
            Assert.AreEqual(f1, f2);
        }

        [TestMethod]
        public void TestSingleton2(){
            SimpleContainer c = new SimpleContainer();

            c.RegisterType<Foo>( false );
            Foo f1 = c.Resolve<Foo>();
            Foo f2 = c.Resolve<Foo>();
            Assert.AreNotEqual(f1, f2);
        }

        [TestMethod]
        public void TestRegister(){
            SimpleContainer c = new SimpleContainer();

            c.RegisterType<IFoo, Foo>( false );
            IFoo f = c.Resolve<IFoo>();
            Assert.AreEqual(f.GetType(), typeof(Foo));
        }

        [TestMethod]
        public void TestRegister2(){
            SimpleContainer c = new SimpleContainer();

            c.RegisterType<IFoo, Bar>( false );
            IFoo f = c.Resolve<IFoo>();
            Assert.AreEqual(f.GetType(), typeof(Bar));
        }

        [TestMethod]
        public void TestRegister3(){
            SimpleContainer c = new SimpleContainer();

            Quz q = c.Resolve<Quz>();
            Assert.AreEqual(q.GetType(), typeof(Quz));
        }

        [TestMethod]
        public void TestRegister4(){
            SimpleContainer c = new SimpleContainer();

            Assert.ThrowsException<ArgumentException>(() => {
                IQuz iq = c.Resolve<IQuz>();
            });
        }

        [TestMethod]
        public void TestRegister5(){
            SimpleContainer c = new SimpleContainer();

            Assert.ThrowsException<ArgumentException>(() => {
                Baz b = c.Resolve<Baz>();
            });
        }

        [TestMethod]
        public void TestRegister6(){
            SimpleContainer c = new SimpleContainer();

            Assert.ThrowsException<ArgumentException>(() => {
                c.RegisterType<IQuz>( false );;
            });
        }

        [TestMethod]
        public void TestRegister7(){
            SimpleContainer c = new SimpleContainer();

            Assert.ThrowsException<ArgumentException>(() => {
                c.RegisterType<IQuz, Qug>( false );;
            });
        }

        [TestMethod]
        public void TestRegister8(){
            SimpleContainer c = new SimpleContainer();

            c.RegisterType<IFoo, Foo>( false );
            c.RegisterType<IFoo, Bar>( false );
            IFoo f = c.Resolve<IFoo>();
            Assert.AreEqual(f.GetType(), typeof(Bar));
        }
    }
}
