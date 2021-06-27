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
            DataAccessHandler<int> SQLhandler = new DataAccessHandler<int>(sumSqlData);
            SQLhandler.Execute();
            Assert.AreEqual(581769, SQLhandler.Result);
        }

        [TestMethod]
        public void TestXML(){
            LongestNodeXMLData longestNode = new LongestNodeXMLData("test.xml");
            DataAccessHandler<string> XMLhandler = new DataAccessHandler<string>(longestNode);
            XMLhandler.Execute();
            Assert.AreEqual("breakfast_menu", XMLhandler.Result);
        }
    }
}
