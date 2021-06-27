using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Solution;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestHeightTreeVisitor(){
            Tree root = new TreeNode(){
                Left = new TreeNode(){
                    Left = new TreeLeaf() { Value = 1 },
                    Right = new TreeLeaf() { Value = 2 }
                },
                Right = new TreeLeaf() { Value = 3 }
            };
            HeightTreeVisitor visitor = new HeightTreeVisitor();
            visitor.Visit(root);
            Assert.AreEqual(visitor.Height, 2);
        }

        [TestMethod]
        public void TestHeightTreeVisitor2(){
            Tree root = new TreeNode(){
                Left = new TreeLeaf() { Value = 3 },
                Right = new TreeNode(){
                    Left = new TreeLeaf() { Value = 1 },
                    Right = new TreeLeaf() { Value = 2 }
                }
            };
            HeightTreeVisitor visitor = new HeightTreeVisitor();
            visitor.Visit(root);
            Assert.AreEqual(visitor.Height, 2);
        }

        [TestMethod]
        public void TestHeightTreeVisitor3(){
            Tree root = new TreeLeaf(){Value = 2};
            HeightTreeVisitor visitor = new HeightTreeVisitor();
            visitor.Visit(root);
            Assert.AreEqual(visitor.Height, 0);
        }
    }
}
