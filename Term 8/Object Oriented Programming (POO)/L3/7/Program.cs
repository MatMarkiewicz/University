using System;

namespace _7
{
    class Program
    {
        static void Main(string[] args)
        {
            IDataProvider DP = new SomeDataProvider();
            IDataFormatter DF = new SomeDataFormatter();
            IReportPrinter RP = new ReportPrinter();
            ReportComposer RC = new ReportComposer(DP, DF, RP);

            RC.ComposeReport();
        }
    }

    public interface IDataProvider{
        public string GetData();
    }

    public class SomeDataProvider : IDataProvider{
        public string GetData(){
            return "Test\ndata.";
        }
    }

    public interface IDataFormatter{
        public string FormatDocument(string data);
    }

    public class SomeDataFormatter : IDataFormatter{
        public string FormatDocument(string data){
            int i = 0;
            string newData = "";
            foreach (string s in data.Split('\n')){
                newData += String.Format("{0}. {1}\n", i++, s);
            }
            return newData;
        }
    }

    public interface IReportPrinter{
        public void PrintReport(string data);
    }

    public class ReportPrinter : IReportPrinter{
        public void PrintReport(string data){
            Console.Write(data);
        }
    }

    public class ReportComposer{
        private IDataProvider _dataProvider;
        private IDataFormatter _dataFormatter;
        private IReportPrinter _reportPrinter;
        public ReportComposer(IDataProvider dataProvider, IDataFormatter dataFormatter, IReportPrinter reportPrinter){
            this._dataProvider = dataProvider;
            this._dataFormatter = dataFormatter;
            this._reportPrinter = reportPrinter;
        }

        public void ComposeReport(){
            string data = _dataProvider.GetData();
            data = _dataFormatter.FormatDocument(data);
            _reportPrinter.PrintReport(data);
        }
    }
}
