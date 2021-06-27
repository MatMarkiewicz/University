using System;
using System.Collections.Generic;

namespace Solution
{

    public class Person { 
        public string Name{get; set;} 
        public override string ToString(){
            return Name;
        }
    }

    /// Brodge 1:

    public interface ILoader{
        List<Person> GetPersons();
    }

    public class XMLLoader : ILoader{
        public List<Person> GetPersons(){
            return new List<Person>(){new Person(){Name="XML person"}};
        }
    }

    public class SQLLoader : ILoader{
        public List<Person> GetPersons(){
            return new List<Person>(){new Person(){Name="SQL person"}};
        }
    }

    public abstract class PersonRegistry1{
        protected ILoader _loader;

        public PersonRegistry1(ILoader loader){
            _loader = loader;
        }

        /// <summary>
        /// Pierwszy stopień swobody - różne wczytywanie
        /// </summary>
        public List<Person> GetPersons(){
            return _loader.GetPersons();
        }
        
        /// <summary>
        /// Drugi stopień swobody - różne użycie
        /// </summary>
        public abstract void NotifyPersons();
    }

    public class SMSPersonRegistry : PersonRegistry1{
        public SMSPersonRegistry(ILoader loader) : base(loader){}

        public override void NotifyPersons(){
            List<Person> persons = GetPersons();
            foreach ( Person person in persons ){
                Console.WriteLine("SMS notify for {0}", person);
            }
        }
    }

    public class EmailPersonRegistry : PersonRegistry1{
        public EmailPersonRegistry(ILoader loader) : base(loader){}

        public override void NotifyPersons(){
            List<Person> persons = GetPersons();
            foreach ( Person person in persons ){
                Console.WriteLine("Email notify for {0}", person);
            }
        }
    }

    /// Bridge 2:

    public interface INotifier{
        void NotifyPerson(Person person);
    }

    public class SMSNotifier : INotifier{
        public void NotifyPerson(Person person){
            Console.WriteLine("SMS notify for {0}", person);
        }
    }

    public class EmailNotifier : INotifier{
        public void NotifyPerson(Person person){
            Console.WriteLine("Email notify for {0}", person);
        }
    }

    public abstract class PersonRegistry2{
        protected INotifier _notifier;

        public PersonRegistry2(INotifier notifier){
            _notifier = notifier;
        }

        /// <summary>
        /// Pierwszy stopień swobody - różne wczytywanie
        /// </summary>
        public abstract List<Person> GetPersons();
        
        /// <summary>
        /// Drugi stopień swobody - różne użycie
        /// </summary>
        public void NotifyPersons(){
            List<Person> persons = GetPersons();
            foreach ( Person person in persons ){
                _notifier.NotifyPerson(person);
            }
        }
    }

    public class XMLPersonRegistry : PersonRegistry2{
        public XMLPersonRegistry(INotifier notifier) : base(notifier) {}

        public override List<Person> GetPersons(){
            return new List<Person>(){new Person(){Name="XML person"}};
        }
    }

    public class SQLPersonRegistry : PersonRegistry2{
        public SQLPersonRegistry(INotifier notifier) : base(notifier) {}

        public override List<Person> GetPersons(){
            return new List<Person>(){new Person(){Name="SQL person"}};
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Bridge 1:");
            ILoader loader = new XMLLoader();
            PersonRegistry1 registry = new EmailPersonRegistry(loader);
            registry.NotifyPersons();

            Console.WriteLine("Bridge 2:");
            INotifier notifier = new SMSNotifier();
            PersonRegistry2 registry2 = new SQLPersonRegistry(notifier);
            registry2.NotifyPersons();
        }
    }
}
