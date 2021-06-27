using System;
using System.Data.SQLite;
using System.Xml;

namespace Solution{

    public interface IDataAccessStrategy<T>{
        void OpenConnection();
        void DownloadData();
        void ProcessData();
        void CloseConnection();
        T GetResult();
    }

    public class DataAccessHandler<T>{
        private IDataAccessStrategy<T> _strategy;
        
        public DataAccessHandler(IDataAccessStrategy<T> strategy){
            _strategy = strategy;
        }

        public void Execute(){
            _strategy.OpenConnection();
            _strategy.DownloadData();
            _strategy.ProcessData();
            _strategy.CloseConnection();
        }

        public T Result{ get{return _strategy.GetResult();} }
    }

    public class SumSQLData : IDataAccessStrategy<int>{
        private string _fileName;
        private SQLiteConnection _con;
        private SQLiteDataReader _rdr;
        public int Result {get; set;}

        public SumSQLData(string fileName){
            _fileName = fileName;
        }

        public void OpenConnection(){
            _con = new SQLiteConnection(_fileName);
            _con.Open();
        }

        public void DownloadData(){
            using var cmd = new SQLiteCommand("SELECT * FROM cars", _con);
            _rdr = cmd.ExecuteReader();
        }

        public void ProcessData(){
            while (_rdr.Read()){
                Result += _rdr.GetInt32(2);
            }
        }

        public void CloseConnection(){
            _con.Close();
        }

        public int GetResult(){
            return Result;
        }
    }

    public class LongestNodeXMLData : IDataAccessStrategy<string>{
        private string _fileName;
        private XmlDocument _doc;
        public string Result {get; set;}

        public LongestNodeXMLData(string fileName){
            _fileName = fileName;
        }

        public void OpenConnection(){
            _doc = new XmlDocument();
        }

        public void DownloadData(){
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

        public void ProcessData(){
            Result = FindLongest(_doc.FirstChild).Name;
        }

        public void CloseConnection(){
            _fileName=null;
        }

        public string GetResult(){
            return Result;
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            SumSQLData sumSqlData = new SumSQLData(@"URI=file:test.db");
            DataAccessHandler<int> SQLhandler = new DataAccessHandler<int>(sumSqlData);
            SQLhandler.Execute();
            Console.Write("Sum: {0}\n", SQLhandler.Result);

            LongestNodeXMLData longestNode = new LongestNodeXMLData("test.xml");
            DataAccessHandler<string> XMLhandler = new DataAccessHandler<string>(longestNode);
            XMLhandler.Execute();
            Console.Write("Longest node name: {0}\n", XMLhandler.Result);
        }
    }
}
