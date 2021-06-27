using System;

namespace przed
{
    class Program
    {
        static void Main(string[] args)
        {
            
            Item[] items = new Item[]{
                new Item(5.99m, "Item1"),
                new Item(3.99m, "AItem2"),
                new Item(2.99m, "Item3"),
                new Item(18.99m, "Item4")
            };

            ITaxCalculator TC = new SomeTaxCalculator();
            IItemSorter IS = new PriceItemSorter();
            var CR = new CashgRegister(TC, IS);
            
            CR.PrintBill(items);
            Console.Write("Total price: {0}\n", CR.CalculatePrice(items));

        }
    }

    public interface ITaxCalculator{
        Decimal CalculateTax( Decimal Price );
    }

    public class SomeTaxCalculator : ITaxCalculator {
        public Decimal CalculateTax( Decimal Price ) { 
            return Decimal.Round(Price * 0.22m, 2);
        }
    }

    public interface IItemSorter{
        void Sort(Item[] items); 
    }

    public class NameItemSorter : IItemSorter{
        public void Sort(Item[] items){
            Array.Sort(items, (x,y)=>x.Name.CompareTo(y.Name));
        }
    }

    public class PriceItemSorter : IItemSorter{
        public void Sort(Item[] items){
            Array.Sort(items, (x,y)=>x.Price.CompareTo(y.Price));
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
        public ITaxCalculator taxCalc;
        public IItemSorter itemSorter;

        public CashgRegister(ITaxCalculator taxCalculator, IItemSorter itemSorter){
            this.taxCalc = taxCalculator;
            this.itemSorter = itemSorter;
        } 

        public Decimal CalculatePrice( Item[] Items ) {
            Decimal _price = 0;
            foreach ( Item item in Items ) {
                 _price += item.Price + taxCalc.CalculateTax( item.Price );
            }
            return _price;
        }
        
        public void PrintBill( Item[] Items ) {
            itemSorter.Sort(Items);

            foreach ( var item in Items ){
                Console.WriteLine( "Description {0} : Price {1} + tax {2}",
                item.Name, item.Price, taxCalc.CalculateTax( item.Price ) );
            }
        }

    }





}