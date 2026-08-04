package gm2d.ui;

import gm2d.ui.Layout.LayoutList;

class StackLayout extends Layout
{
   var offsetLeft:Float;
   var offsetRight:Float;
   var offsetTop:Float;
   var offsetBottom:Float;

   var mChildren:LayoutList;

   public function new()
   {
      mChildren = [];
      offsetLeft = offsetRight = offsetTop = offsetBottom = 0;
      super();
   }

   override public function findTextLayout() : TextLayout
   {
      return Layout.findTextLayoutInList(mChildren);
   }
   override public function visitChildren(onChild:Layout->Dynamic,inRecurse=true) : Dynamic
      return Layout.visitChildList(mChildren, onChild,inRecurse);


/*
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      if (inWidth!=null)
         width = inWidth;
      else
         width = getBestWidth();

      height = getBestHeight();
   }
*/

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      for(child in mChildren)
         alignChild(child,inX+borderLeft, inY+borderTop, inW-borderLeft-borderRight, inH-borderTop-borderBottom );

      super.setRect(inX, inY, inW, inH);
   }

   public override function add(inLayout:Layout) : Layout
   {
      mChildren.push(inLayout);
      return this;
   }

   override public function clear()
   {
      mChildren = [];
   }


   // StackLayout
   public override function getMinSize(?inWidth:Null<Float>) : Size
   {
      var childWidth = inWidth==null ? null : inWidth - borderLeft - borderRight;
      var w:Float = minWidth;
      var h:Float = minHeight;
      for(c in mChildren)
      {
         var s = c.getMinSize(childWidth);
         if (s.x>w)
            w = s.x;
         if (s.y>h)
            h = s.y;
      }
      return bestDefault(new Size( w, h ));
   }


   public override function getBestWidth() : Float
   {
      var width = 0.0;
      var idx = 0;
      for(child in mChildren)
      {
         var w = child.getBestWidth();
         if (idx>0)
            w+=offsetLeft+offsetRight;
         if (w>width)
            width=w;
         idx++;
      }
      width += borderLeft + borderRight;
      if (minWidth>width) width = minWidth;
      return width;

   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var w:Null<Float> = inWidth==null ? null  : inWidth - borderLeft - borderRight;
      var height = 0.0;
      var idx = 0;
      for(child in mChildren)
      {
         var h = child.getBestHeight(w);
         if (idx>0)
            h+=offsetTop+offsetBottom;
         if (h>height)
            height=h;
         idx++;
      }
      height += borderTop + borderBottom;
      if (minHeight>height) height = minHeight;
      return height;
   }

   override public function toString() return 'StackLayout($name)';
}
