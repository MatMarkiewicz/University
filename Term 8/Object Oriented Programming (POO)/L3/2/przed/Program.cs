using System;

namespace przed
{
    class Program
    {
        static void Main(string[] args)
        {
            ReportPrinter RP = new ReportPrinter();
            RP.PrintReport();
        }
    }

    public class ReportPrinter{

        private string data;

        public string GetData(){
            return "Test\ndata.";
        }
        public void FormatDocument(){
            int i = 0;
            string newData = "";
            foreach (string s in data.Split('\n')){
                newData += String.Format("{0}. {1}\n", i++, s);
            }
            data = newData;
        }

        public void PrintReport(){
            data = GetData();
            FormatDocument();
            Console.Write(data);
        }

    }

}

