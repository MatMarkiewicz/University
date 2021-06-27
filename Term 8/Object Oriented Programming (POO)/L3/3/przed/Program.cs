using System;

namespace przed
{
    class Program
    {
        static void Main(string[] args)
        {
            
            Item[] items = new Item[]{
                new Item(1.99m, "Item1"),
                new Item(3.99m, "Item2"),
                new Item(2.99m, "Item3"),
                new Item(18.99m, "Item4")
            };

            var CR = new CashgRegister();
            
            CR.PrintBill(items);
            Console.Write("Total price: {0}\n", CR.CalculatePrice(items));

        }
    }

    public class TaxCalculator {
        public Decimal CalculateTax( Decimal Price ) { 
            return Decimal.Round(Price * 0.22m, 2);
        }
    }

    public class Item{
        public Item(decimal price, string name){
            this.Name = name;
            this.Price = price;
        }
        public string Name{get;}
        public Decimal Price{get;}
    }

    public class CashgRegister{
        public TaxCalculator taxCalc = new TaxCalculator();

        public Decimal CalculatePrice( Item[] Items ) {
            Decimal _price = 0;
            foreach ( Item item in Items ) {
                 _price += item.Price + taxCalc.CalculateTax( item.Price );
            }
            return _price;
        }
        
        public void PrintBill( Item[] Items ) {
            foreach ( var item in Items ){
                Console.WriteLine( "Description {0} : Price {1} + tax {2}",
                item.Name, item.Price, taxCalc.CalculateTax( item.Price ) );
            }
        }

    }





}
