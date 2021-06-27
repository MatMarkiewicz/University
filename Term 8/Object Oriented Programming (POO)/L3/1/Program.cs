using System;

namespace _1
{

    /*
    1. Creator - stworzyłem fabryke dla klasy DataProvider, dzięki czemu w późniejszej
    wersji kodu możemy stworzyć klasę BetterDataProvider bez zmian po stronie klienta

    2. High Cohesion - metody wewnątrz klas są ze sobą mocno związane oraz spójne,
    klasy są niewielkie

    3. Polymorphism - Wykorzystałem dziedziczenie tworząc BetterDataProvider.
    DataProvider.DownloadData jest nadpisywana jest BetterDataProvider.DownloadData,
    co więcej DataProvider.GetData również może zostać nadpisana w przyszłości. 
    
    4. Pure fabrication - zamiast tworzenia metody Print wewnątrz klasy Data
    zdecydowałem się stworzyć nową klasę DataPrinter, dla której jest to jedyna odpowiedzialność.
    W ten sposób upewniam się, że nie złamię zasady High Cohesion (klasa Data może już 
    posiadać metodę lub metody, do których Print by nie pasował)

    5. Protected Variations - DataPriveder ma metodę GetData, pod którą schowana jest 
    implementacja uzyskiwania danych, dzięki temu klient może być pewny, że jego kod 
    odpowiedzialny za pozyskanie nie zmieni się, zawsze będzie mógł uzyskac nowy obiekt
    DataPrinter z fabryki, który będzie miał metodę GetData
    */

    class Program
    {
        static void Main(string[] args)
        {
            DataProvider DP = new FactoryOfDataProvider().CreateDataProvider();
            Data data = DP.GetData();
            
            DataPrinter printer = new DataPrinter();
            printer.PrintData(data);
        }
    }

    public class DataPrinter{
        public void PrintData(Data data){
            Console.Write(data.Content);
        }
    }

    public class Data{
        public string Content{get;set;}

        // structure of a data
    }

    public class DataProvider{
        protected Data _data;

        public virtual void DownloadData(){
            // some complicated implementation of getting data
            _data = new Data{Content = "Data.\n"};
        }

        /// Stabel method
        public virtual Data GetData(){
            this.DownloadData();
            return _data;
        }
    }

    public  class BetterDataProvider : DataProvider{

        public override void DownloadData()
        {
            // even more complicated implementation of getting data
            _data = new Data{Content = "Better Data.\n"};
        }
    }

    public class FactoryOfDataProvider{
        public DataProvider CreateDataProvider(){
            // return new DataProvider();
            return new BetterDataProvider();
        }
    }

}
