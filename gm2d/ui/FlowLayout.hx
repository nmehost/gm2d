package gm2d.ui;

import gm2d.ui.Layout.LayoutList;

class FlowLayout extends Layout
{
   var mChildren:LayoutList;
   public var rowAlign:Int;
   var spaceX:Float;
   var spaceY:Float;

   public function new()
   {
      super();
      rowAlign = Layout.AlignLeft;
      mChildren = [];
      spaceX = spaceY = 0.0;
      setAlignment(Layout.AlignStretch);
   }

   override public function findTextLayout() : TextLayout
   {
      return Layout.findTextLayoutInList(mChildren);
   }



   public function setRowAlign(inAlign:Int)
   {
      rowAlign = inAlign;
      return this;
   }

   public override function setSpacing(inX:Float, inY:Float)
   {
      spaceX = inX;
      spaceY = inY;
      return this;
   }

/*
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      if (inWidth!=null)
         width = inWidth;
      else
         width = getBestWidth();

      if (inHeight!=null)
         height = inHeight;
      else
         height = getBestHeight(width);
   }
   */

   function layoutRow(i0:Int, i1:Int, x0:Float, y0:Float, rowW:Float, rowH:Float, maxW:Float)
   {
      switch(rowAlign & Layout.AlignMaskX)
      {
         case Layout.AlignCenterX:
            x0 += (maxW-rowW)*0.5;
         case Layout.AlignRight:
            x0 += (maxW-rowW);
      }

      for(i in i0...i1)
      {
         var child = mChildren[i];
         var w = child.getBestWidth();
         if (w>rowW) w = rowW;
         var h = child.getBestHeight(w);

         var y = y0;
         var setH = rowH;

         switch(rowAlign & Layout.AlignMaskY)
         {
            case Layout.AlignCenterY:
               y += (rowH-h)*0.5;
               setH = h;
            case Layout.AlignBottom:
               y += (maxW-rowW);
               setH = h;
            case Layout.AlignTop:
               setH = h;
         }

         alignChild(child, x0, y, w, setH );

         x0 += w + spaceX;
      }
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var y = borderTop + inY;
      var rowWidth = 0.0;
      var rowHeight = 0.0;
      var c0 = 0;
      var maxW = inW - borderLeft - borderRight;

      for(i in 0...mChildren.length)
      {
         var child = mChildren[i];

         var w = child.getBestWidth();
         var h = child.getBestHeight(w);
         if (rowWidth>0 && rowWidth+w > maxW)
         {
            layoutRow(c0,i,inX+borderLeft, y, rowWidth - spaceX,rowHeight, maxW);
            rowWidth = 0;
            c0 = i;
            y += rowHeight + spaceY;
            rowHeight = 0;
         }

         rowWidth += w + spaceX;
         if (h>rowHeight)
            rowHeight = h;
      }
      if (c0<mChildren.length)
      {
        layoutRow(c0,mChildren.length,inX+borderLeft, y, rowWidth - spaceX,rowHeight, maxW);
      }

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


   public override function getBestWidth() : Float
   {
      var width = 0.0;
      for(child in mChildren)
      {
         if (width>0)
            width += spaceX;
         var w = child.getBestWidth();
         width += w;
      }
      width += borderLeft + borderRight;
      if (minWidth>width) width = minWidth;
      return width;

   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var height = borderTop + borderBottom;
      var rowHeight = 0.0;
      var x = 0.0;
      var maxW = inWidth==null ? 0 : inWidth-borderLeft- borderRight;
      for(child in mChildren)
      {
         var w = child.getBestWidth();
         var checkW = x>0 ? w+spaceX : w;
         if (inWidth!=null && w>maxW)
            w = maxW;
         var h = child.getBestHeight(w);
         if (x>0 && inWidth!=null && x+checkW > maxW)
         {
            x = 0;
            if (height>0)
               height += spaceY;
            height += rowHeight;
            rowHeight = 0;
         }
         if (x>0)
            x+=spaceX;
         x+=w;
         if (h>rowHeight)
            rowHeight = h;
      }
      if (height>0) height+=spaceY;
      height += rowHeight;
      if (minHeight>height) height = minHeight;

      return height;
   }


   override public function toString() return 'FlowLayout($name)';
}
