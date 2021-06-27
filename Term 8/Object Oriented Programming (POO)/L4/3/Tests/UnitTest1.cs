using Microsoft.VisualStudio.TestTools.UnitTesting;
using Solution;
using System;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestAcquire(){
            Airport airport = new Airport(1);
            Plane plane = airport.AcquirePlane();
            Assert.IsNotNull(plane);
        }

        [TestMethod]
        public void TestAcquire2(){
            Airport airport = new Airport(2);
            Plane plane = airport.AcquirePlane();
            Plane plane2 = airport.AcquirePlane();
            Assert.IsNotNull(plane);
            Assert.IsNotNull(plane2);
            Assert.AreNotSame(plane, plane2);
        }

        [TestMethod]
        public void TestNegativeCapacity(){
            Assert.ThrowsException<ArgumentException>(() => {
                Airport airport = new Airport(-1);
            });
        }

        [TestMethod]
        public void TestZeroCapacity(){
            Assert.ThrowsException<ArgumentException>(() => {
                Airport airport = new Airport(0);
            });
        }

        [TestMethod]
        public void TestRelease(){
            Airport airport = new Airport(1);
            Plane plane = airport.AcquirePlane();
            airport.ReleasePlane(plane);
            Plane plane2 = airport.AcquirePlane();
            Assert.IsNotNull(plane);
            Assert.IsNotNull(plane2);
            Assert.AreSame(plane, plane2);
        }

        [TestMethod]
        public void TestRelease2(){
            Airport airport = new Airport(1);
            Plane plane = airport.AcquirePlane();
            Plane plane2 = new Plane();
            Assert.ThrowsException<ArgumentException>(() => {
                airport.ReleasePlane(plane2);
            });
        }

    }
}
