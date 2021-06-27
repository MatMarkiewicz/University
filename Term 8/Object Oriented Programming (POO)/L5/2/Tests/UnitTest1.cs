using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;
using System.Text;
using System.Linq;
using Solution;

namespace Tests
{

    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestCaesarStream(){
            byte[] buffer = Encoding.UTF8.GetBytes("Tlt");
            MemoryStream memStream = new MemoryStream();
            CaesarStream cMemStream = new CaesarStream(memStream, 3);
            cMemStream.Write(buffer, 0, buffer.Length);
            Assert.AreEqual("Wow", Encoding.UTF8.GetString(memStream.ToArray()));
        }
    
        [TestMethod]
        public void TestCaesarStream2(){
            byte[] buffer = Encoding.UTF8.GetBytes("Zrz");
            MemoryStream memStream = new MemoryStream();
            CaesarStream cMemStream = new CaesarStream(memStream, -3);
            cMemStream.Write(buffer, 0, buffer.Length);
            Assert.AreEqual("Wow", Encoding.UTF8.GetString(memStream.ToArray()));
        }

        [TestMethod]
        public void TestCaesarStream3(){
            byte[] buffer = Encoding.UTF8.GetBytes("Zrz");
            MemoryStream memStream = new MemoryStream();
            CaesarStream cMemStream = new CaesarStream(memStream, 253);
            cMemStream.Write(buffer, 0, buffer.Length);
            Assert.AreEqual("Wow", Encoding.UTF8.GetString(memStream.ToArray()));
        }

        [TestMethod]
        public void TestCaesarStream4(){
            byte[] buffer = Encoding.UTF8.GetBytes("Wow");
            MemoryStream memStream = new MemoryStream();
            CaesarStream cMemStream = new CaesarStream(memStream, 5);
            cMemStream.Write(buffer, 0, buffer.Length);
            CaesarStream cMemStream2 = new CaesarStream(cMemStream, -5);
            cMemStream2.Read(buffer, 0, buffer.Length);
            Assert.AreEqual("Wow", Encoding.UTF8.GetString(buffer));
        }
    }
}
