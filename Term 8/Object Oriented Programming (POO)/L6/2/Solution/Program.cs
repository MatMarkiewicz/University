using System;
using System.Collections.Generic;

namespace Solution
{

    public class Context{
        private Dictionary<string, bool> _contex = new Dictionary<string, bool>();

        public bool GetValue( string VariableName ){
            if (_contex.ContainsKey(VariableName)){
                return _contex[VariableName];
            } else{
                throw new ArgumentException("Variable not found in given context.");
            }
        }

        public void SetValue( string VariableName, bool Value ){
            if (_contex.ContainsKey(VariableName)){
                _contex.Remove(VariableName);
            }
            _contex.Add(VariableName, Value);
        }
    }
    
    public abstract class AbstractExpression{
        public abstract bool Interpret(Context context);
    }

    public class ConstExpression : AbstractExpression{
        private bool _value;

        public ConstExpression(bool value){
            _value = value;
        }

        public override bool Interpret(Context context){
            return _value;
        }
    }

    public class VarExpression : AbstractExpression{
        private string _varName;

        public VarExpression(string varName){
            _varName = varName;
        }

        public override bool Interpret(Context context){
            return context.GetValue(_varName);
        }
    }

    public abstract class BinaryExpression : AbstractExpression{
        protected AbstractExpression _leftExpression;
        protected AbstractExpression _rightExpression;

        public BinaryExpression(AbstractExpression leftExpression, AbstractExpression rightExpression){
            _leftExpression = leftExpression;
            _rightExpression = rightExpression;
        }
    }

    public class AndExpression : BinaryExpression{
        public AndExpression(AbstractExpression leftExpression, AbstractExpression rightExpression) : base(leftExpression, rightExpression){}

        public override bool Interpret(Context context){
            return _leftExpression.Interpret(context) && _rightExpression.Interpret(context);
        }
    }

    public class OrExpression : BinaryExpression{
        public OrExpression(AbstractExpression leftExpression, AbstractExpression rightExpression) : base(leftExpression, rightExpression){}

        public override bool Interpret(Context context){
            return _leftExpression.Interpret(context) || _rightExpression.Interpret(context);
        }
    }

    public abstract class UnaryExpression : AbstractExpression{
        protected AbstractExpression _expression;

        public UnaryExpression(AbstractExpression expression){
            _expression = expression;
        }
    }

    public class NegExpression : UnaryExpression{
        public NegExpression(AbstractExpression expression) : base(expression) {}

        public override bool Interpret(Context context){
            return !_expression.Interpret(context);
        }
    }
 

    class Program
    {
        static void Main(string[] args)
        {
            Context ctx = new Context();
            ctx.SetValue( "x", false );
            ctx.SetValue( "y", true );

            AbstractExpression exp = new AndExpression(
                new OrExpression(
                    new VarExpression("x"),
                    new VarExpression("y")
                ),
                new AndExpression(
                    new VarExpression("y"),
                    new ConstExpression(true)
                )
            );

            bool Value = exp.Interpret( ctx );

            Console.WriteLine("Expression value: {0}", Value);
        }
    }
}
