using System;

/*
W tym przypadku po refaktoryzacji powstały 3 klasy,
ponieważ 3 metody miały 3 inne odpowiedzialności.
Po zmianach 1 klasa odpowiada za dostarczenie danych,
jedna za ich formatowanie, a jedna za ich printowanie.
Nie zawsze jednak będzie tak, że refaktoryzacja wymusi, 
by każda metoda trafiła do osobnej klasy,
przykładem są metody rusz i zatrzymaj w klasie samochód.
*/

namespace po
{
    class Program
    {
        static void Main(string[] args)
        {
            IDataProvider DP = new SomeDataProvider();
            IDataFormatter DF = new SomeDataFormatter();
            ReportPrinter RP = new ReportPrinter();

            string data = DP.GetData();
            data = DF.FormatDocument(data);
            RP.PrintReport(data);
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

    public class ReportPrinter{
        public void PrintReport(string data){
            Console.Write(data);
        }
    }

}
