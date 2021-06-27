using System;
using System.Data.SQLite;
using System.Xml;

namespace Solution
{

    public abstract class DataAccessHandler{
        protected abstract void OpenConnection();
        protected abstract void DownloadData();
        protected abstract void ProcessData();
        protected abstract void CloseConnection();

        public void Execute(){
            OpenConnection();
            DownloadData();
            ProcessData();
            CloseConnection();
        }
    }

    public class SumSQLData : DataAccessHandler{
        private string _fileName;
        private SQLiteConnection _con;
        private SQLiteDataReader _rdr;
        public int Result {get; set;}

        public SumSQLData(string fileName){
            _fileName = fileName;
        }

        protected override void OpenConnection(){
            _con = new SQLiteConnection(_fileName);
            _con.Open();
        }

        protected override void DownloadData(){
            using var cmd = new SQLiteCommand("SELECT * FROM cars", _con);
            _rdr = cmd.ExecuteReader();
        }

        protected override void ProcessData(){
            while (_rdr.Read()){
                Result += _rdr.GetInt32(2);
            }
        }

        protected override void CloseConnection(){
            _con.Close();
        }
    }

    public class LongestNodeXMLData : DataAccessHandler{
        private string _fileName;
        private XmlDocument _doc;
        public string Result {get; set;}

        public LongestNodeXMLData(string fileName){
            _fileName = fileName;
        }

        protected override void OpenConnection(){
            _doc = new XmlDocument();
        }

        protected override void DownloadData(){
            _doc.Load(_fileName);
        }

        private XmlNode FindLongest(XmlNode node){
            XmlNode longest = node;

            foreach (XmlNode child in node.ChildNodes){
                XmlNode res = FindLongest(child);
                if (res.Name.Length > longest.Name.Length){
                    longest = res;
                }
            }

            if (node.NextSibling!=null){
                XmlNode res = FindLongest(node.NextSibling);
                if (res.Name.Length > longest.Name.Length){
                    longest = res;
                }
            }

            return longest;

        }

        protected override void ProcessData(){
            Result = FindLongest(_doc.FirstChild).Name;
        }

        protected override void CloseConnection(){
            _fileName=null;
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            SumSQLData sumSqlData = new SumSQLData(@"URI=file:test.db");
            sumSqlData.Execute();
            Console.Write("Sum: {0}\n", sumSqlData.Result);

            LongestNodeXMLData longestNode = new LongestNodeXMLData("test.xml");
            longestNode.Execute();
            Console.Write("Longest node name: {0}\n", longestNode.Result);
        }
    }
}
