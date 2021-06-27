using System;

namespace Solution
{

    public abstract class Tree{
    }

    public class TreeNode : Tree{
        public Tree Left { get; set; }
        public Tree Right { get; set; }
    }

    public class TreeLeaf : Tree{
        public int Value { get; set; }
    }

    public abstract class TreeVisitor{

        public void Visit( Tree tree ){
            if (tree is TreeNode)
                this.VisitNode( (TreeNode)tree );
            if (tree is TreeLeaf)
                this.VisitLeaf( (TreeLeaf)tree );
        }

        public virtual void VisitNode( TreeNode node ){
            if ( node != null ){
                this.Visit( node.Left );
                this.Visit( node.Right );
            }
        }

        public virtual void VisitLeaf( TreeLeaf leaf ){}
    }

    public class SumTreeVisitor : TreeVisitor{
        public int Sum { get; set; }
        public override void VisitLeaf( TreeLeaf leaf ){
            base.VisitLeaf( leaf );
            this.Sum += leaf.Value;
        }
    }

    public class HeightTreeVisitor : TreeVisitor{
        public int Height{ get; set; }
        public int TempHeight{ get; set; }

        public override void VisitNode(TreeNode node ){
            TempHeight++;
            base.VisitNode(node);
            TempHeight--;
        }

        public override void VisitLeaf( TreeLeaf leaf ){
            if (TempHeight > Height){
                Height = TempHeight;
            }
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Tree root = new TreeNode(){
                Left = new TreeNode(){
                    Left = new TreeLeaf() { Value = 1 },
                    Right = new TreeLeaf() { Value = 2 }
                },
                Right = new TreeLeaf() { Value = 3 }
            };
            SumTreeVisitor visitor = new SumTreeVisitor();
            HeightTreeVisitor visitor2 = new HeightTreeVisitor();
            visitor.Visit( root );
            visitor2.Visit(root);
            Console.WriteLine( "Suma wartości na drzewie to {0}", visitor.Sum );
            Console.WriteLine( "Głębokość drzewa to {0}", visitor2.Height );
        }
    }
}
