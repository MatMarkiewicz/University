using System;
using System.Collections.Generic;
using System.Reflection;

namespace DI_engine
{

    public abstract class Policy{
        protected readonly Type _type;

        public Policy(Type type){
            _type = type;
        }

        public virtual object GetInstance(){
            foreach (var constructor in _type.GetConstructors()){
                if (constructor.GetParameters().Length == 0){
                    return constructor.Invoke(new object[]{});
                }
            }
            throw new ArgumentException(string.Format("Type {0} does not have non parameterized constructor.", _type));
        }
    }

    public class SingletonPolicy : Policy{
        private static readonly Dictionary<Type, object> _instances = new Dictionary<Type, object>();

        public SingletonPolicy(Type type) : base(type){}

        public override object GetInstance(){
            if (!_instances.ContainsKey(_type)){
                _instances[_type] = base.GetInstance();
            }
            return _instances[_type];
        }
    }

    public class TransientPolicy : Policy{
        public TransientPolicy(Type type) : base(type){}

        public override object GetInstance(){
            return base.GetInstance();
        }
    }

    public class SimpleContainer{
        private readonly Dictionary<Type, Policy> _registeredTypes = new Dictionary<Type, Policy>();

        private Policy GetPolicy<T>(bool Singleton){
            if (Singleton){
                return new SingletonPolicy(typeof(T));
            }
            return new TransientPolicy(typeof(T));
        }

        public void RegisterType<T>( bool Singleton ) where T : class{
            if (typeof(T).GetTypeInfo().IsAbstract){
                throw new ArgumentException(string.Format("Type {0} is abstract.", typeof(T)));
            }
            _registeredTypes[typeof(T)] = GetPolicy<T>(Singleton);
        }

        public void RegisterType<From, To>( bool Singleton ) where To : From{
            if (typeof(To).GetTypeInfo().IsAbstract){
                throw new ArgumentException(string.Format("Type {0} is abstract.", typeof(To)));
            }
            _registeredTypes[typeof(From)] = GetPolicy<To>(Singleton);
        }

        public T Resolve<T>(){
            if (_registeredTypes.ContainsKey(typeof(T))){
                return (T)_registeredTypes[typeof(T)].GetInstance();
            }
            if (typeof(T).GetTypeInfo().IsAbstract){
                throw new ArgumentException(string.Format("Abstract type {0} is not yet registered.", typeof(T)));
            }
            return (T)GetPolicy<T>(false).GetInstance();
        }

    }

    class Program
    {

        public interface IFoo{}
        public class Foo :IFoo{}
        public class Bar :IFoo{}
        public class Quz{}
        public interface IQuz{}
        public abstract class Baz{}

        static void Main(string[] args){

            //SimpleContainer c = new SimpleContainer();

            // c.RegisterType<Foo>( true );
            // Foo f1 = c.Resolve<Foo>();
            // Foo f2 = c.Resolve<Foo>();
            // Console.WriteLine(f1==f2);

            // c.RegisterType<Bar>( false );
            // Bar b1 = c.Resolve<Bar>();
            // Bar b2 = c.Resolve<Bar>();
            // Console.WriteLine(b1!=b2);

            // c.RegisterType<IFoo, Foo>( false );
            // IFoo f = c.Resolve<IFoo>();
            // Console.WriteLine(f.GetType());

            // c.RegisterType<IFoo, Bar>( false );
            // IFoo g = c.Resolve<IFoo>();
            // Console.WriteLine(g.GetType());

            // Quz q = c.Resolve<Quz>();
            // Console.WriteLine(q.GetType());

            // IQuz iq = c.Resolve<IQuz>();
        }
    }
}
