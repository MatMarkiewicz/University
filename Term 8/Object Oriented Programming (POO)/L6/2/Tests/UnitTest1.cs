using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Solution;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestConstant(){
            Context ctx = new Context();
            AbstractExpression exp = new ConstExpression(true);
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestConstant2(){
            Context ctx = new Context();
            AbstractExpression exp = new ConstExpression(false);
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestNeg(){
            Context ctx = new Context();
            AbstractExpression exp = new NegExpression(new ConstExpression(false));
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestNeg2(){
            Context ctx = new Context();
            AbstractExpression exp = new NegExpression(new ConstExpression(true));
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestOr(){
            Context ctx = new Context();
            AbstractExpression exp = new OrExpression(new ConstExpression(true), new ConstExpression(true));
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestOr2(){
            Context ctx = new Context();
            AbstractExpression exp = new OrExpression(new ConstExpression(false), new ConstExpression(true));
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestOr3(){
            Context ctx = new Context();
            AbstractExpression exp = new OrExpression(new ConstExpression(true), new ConstExpression(false));
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestOr4(){
            Context ctx = new Context();
            AbstractExpression exp = new OrExpression(new ConstExpression(false), new ConstExpression(false));
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestAnd(){
            Context ctx = new Context();
            AbstractExpression exp = new AndExpression(new ConstExpression(true), new ConstExpression(true));
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestAnd2(){
            Context ctx = new Context();
            AbstractExpression exp = new AndExpression(new ConstExpression(false), new ConstExpression(true));
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestAnd3(){
            Context ctx = new Context();
            AbstractExpression exp = new AndExpression(new ConstExpression(true), new ConstExpression(false));
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestAnd4(){
            Context ctx = new Context();
            AbstractExpression exp = new AndExpression(new ConstExpression(false), new ConstExpression(false));
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestContext(){
            Context ctx = new Context();
            ctx.SetValue("x", false);
            AbstractExpression exp = new VarExpression("x");
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }

        [TestMethod]
        public void TestContext2(){
            Context ctx = new Context();
            ctx.SetValue("x", true);
            AbstractExpression exp = new VarExpression("x");
            bool Value = exp.Interpret(ctx);
            Assert.IsTrue(Value);
        }

        [TestMethod]
        public void TestContext3(){
            Context ctx = new Context();
            ctx.SetValue("x", true);
            AbstractExpression exp = new VarExpression("y");
            Assert.ThrowsException<ArgumentException>(() => {
                bool Value = exp.Interpret(ctx);
            });
        }

        [TestMethod]
        public void TestContext4(){
            Context ctx = new Context();
            ctx.SetValue("x", true);
            ctx.SetValue("x", false);
            AbstractExpression exp = new VarExpression("x");
            bool Value = exp.Interpret(ctx);
            Assert.IsFalse(Value);
        }
    }
}
