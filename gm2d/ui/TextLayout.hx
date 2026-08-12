package gm2d.ui;

import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.geom.Point;

class TextLayout extends DisplayLayout
{
   public function new(inObj:TextField,inAlign:Int = 0x24, // AlignCenterX|AlignCenterY
           ?inPrefWidth:Null<Float>,?inPrefHeight:Null<Float>)
   {
      super(inObj,inAlign);

      var w = inObj.width;
      var h = inObj.height;
      if (inObj.rotation==90 || inObj.rotation==270)
      {
         var t = w; w = h; h = t;
      }
      var fmt = inObj.defaultTextFormat;
      if (fmt!=null && fmt.size!=null)
      {
         //trace("  fmt size: " + fmt.size + " lines:" + inObj.numLines );
         if (inObj.rotation==90 || inObj.rotation==270)
            w = fmt.size * 1.5 * inObj.numLines;
         else
            h = fmt.size * 1.5 * inObj.numLines;
      }

      mOWidth = inPrefWidth==null ? w: inPrefWidth;
      mOHeight = inPrefHeight==null ? h: inPrefHeight;

      mDebugCol = 0x00ff00;
   }

   public function updateSizeFromText()
   {
      var w = mObj.width;
      var h = mObj.height;
      if (mObj.rotation==90 || mObj.rotation==270)
      {
         var t = w; w = h; h = t;
      }
      mOWidth = w;
      mOHeight = h;
   }

   override public function findTextLayout() : TextLayout  { return this; }

   override public function renderDebug(pos:Point, w:Float, h:Float)
   {
     var text:TextField = cast mObj;
     Layout.mDebug.lineStyle(2,mDebugCol);
     Layout.mDebug.drawRect(pos.x,pos.y,text.textWidth,text.textHeight);
   }


   override public function getBaseWidth()
   {
      var text:TextField = cast mObj;
      if (text.rotation==90 || text.rotation==270)
          return text.height;
      return text.width;
   }
   override public function getBaseHeight()
   {
      var text:TextField = cast mObj;
      if (text.rotation==90 || text.rotation==270)
          return text.width;
      return text.height;
   }

   override function setObjRect(x:Float,y:Float,w:Float,h:Float)
   {
      var text:TextField = cast mObj;
      text.x = x;
      text.y = y;
      if (text.rotation==90 || text.rotation==270)
      {
         text.width = h;
         text.height = w;
         if (text.rotation==270)
            text.y = y+h;
         else
         {
            text.x = x+w;
         }
      }
      else
      {
         text.autoSize = TextFieldAutoSize.NONE;
         text.width = w;
         text.height = h;
      }
   }


   // TextLayout
   public override function getBestWidth() : Float
   {
      var w = bestWidth!=null ? bestWidth : mOWidth + borderLeft + borderRight;
      return clampBestWidth(w);
   }


   // Reflows the text field at inWidth and measures its actual rendered height (including
   // borders). Shared by getBestHeight() and getMinSize() so both report the real content
   // height when a width is known, instead of the fixed fmt.size*1.5 heuristic.
   function reflowHeight(inWidth:Float) : Float
   {
      var textF:TextField = cast mObj;
      var a = textF.autoSize;
      var w = textF.width;
      textF.autoSize = TextFieldAutoSize.LEFT;
      textF.width = inWidth - borderLeft - borderRight;
      var h = textF.height + borderTop + borderBottom;
      textF.autoSize = a;
      textF.width = w;
      return h;
   }

   // TextLayout
   public override function getMinSize(?inWidth:Null<Float>) : Size
   {
      var textF:TextField = cast mObj;
      if (minHeight<0 && textF.multiline && (mObj.rotation==0 || mObj.rotation==180))
      {
         var h = -1.0;
         if (inWidth!=null)
            h = reflowHeight(inWidth);
         else
         {
            var fmt = textF.defaultTextFormat;
            if (fmt!=null && fmt.size!=null)
               h = fmt.size * 1.5 + borderTop + borderBottom;
         }

         return bestDefault(new Size(minWidth>=0? minWidth : mOWidth + borderLeft + borderRight, h) );
      }

      return super.getMinSize(inWidth);

      //return bestDefault(new Size(mOWidth>minWidth ? mOWidth:minWidth, mOHeight>minHeight ? mOHeight:minHeight ));
   }

   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      if (bestHeight!=null)
         return clampBestHeight(bestHeight, inWidth);
      var textF:TextField = cast mObj;
      if (textF.multiline && inWidth!=null && (mObj.rotation==0 || mObj.rotation==180))
         return clampBestHeight(reflowHeight(inWidth), inWidth);
      return super.getBestHeight(inWidth);
   }

   override public function toString()
   {
      var textF:TextField = cast mObj;
      var text =  textF.text;
      if (text.length>10)
         text = text.substr(0,7) + "...";

      return 'TextLayout($name : $text)';
   }
}
