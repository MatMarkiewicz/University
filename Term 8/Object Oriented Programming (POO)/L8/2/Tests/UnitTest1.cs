using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data.SQLite;
using System.Xml;
using Solution;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestSQL(){
            SumSQLData sumSqlData = new SumSQLData(@"URI=file:test.db");
            sumSqlData.Execute();
            Assert.AreEqual(581769, sumSqlData.Result);
        }

        [TestMethod]
        public void TestXML(){
            LongestNodeXMLData longestNode = new LongestNodeXMLData("test.xml");
            longestNode.Execute();
            Assert.AreEqual("breakfast_menu", longestNode.Result);
        }
    }
}
