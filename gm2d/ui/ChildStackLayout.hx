package gm2d.ui;

// In a child stack, the top item owns the others, so the offset
//  applies to this item only, and the others get it because they are
//  children
class ChildStackLayout extends StackLayout
{

   public function new()
   {
      super();
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      if (Layout.mDebug!=null)
      {
         Layout.mDebug.lineStyle(1,0xffff00);
         Layout.mDebug.drawRect(inX,inY,inW,inH);
      }

      var new_w = inW-borderLeft-borderRight;
      var new_h = inH-borderTop-borderBottom;
      for(i in 0...mChildren.length)
      {
         var child = mChildren[i];
         if (i==0)
         {
            //trace("Set stack parent " +   (inX+borderLeft) + "," + (inY+borderTop) + ' $new_w x $new_h' );
            alignChild(child, inX+borderLeft, inY+borderTop, new_w, new_h );
            new_w -= offsetLeft + offsetRight;
            new_h -= offsetTop + offsetBottom;
         }
         else
         {
            //trace('Set stack child $offsetLeft,$offsetRight,$new_w,$new_h');
            alignChild(child,offsetLeft,offsetRight,new_w,new_h);
         }

     }

      super.setRect(inX, inY, inW, inH);
   }

   public function setChildPadding(left:Float, top:Float, right:Float, bottom:Float)
   {
      offsetLeft = left;
      offsetRight = right;
      offsetTop = top;
      offsetBottom = bottom;
   }
   override public function toString() return 'ChildStackLayout($name)';
}
