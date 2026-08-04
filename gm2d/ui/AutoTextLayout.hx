package gm2d.ui;

import nme.text.TextField;
import nme.text.TextFieldAutoSize;

class AutoTextLayout extends TextLayout
{
   public function new(inObj:TextField,inAlign:Int = 0x24, // AlignCenterX|AlignCenterY
           ?inPrefWidth:Null<Float>,?inPrefHeight:Null<Float>)
   {
      inObj.autoSize = TextFieldAutoSize.LEFT;
      //trace(" " + inObj.text + " autos " + inObj.autoSize);
      super(inObj,inAlign,inPrefWidth,inPrefHeight);
      inObj.autoSize = TextFieldAutoSize.NONE;
   }

   override public function updateSizeFromText()
   {
      var tf:TextField = cast mObj;
      if (tf!=null)
      {
         var as = tf.autoSize;
         tf.autoSize = TextFieldAutoSize.LEFT;
         super.updateSizeFromText();
         tf.autoSize = as;
      }
      else
      {
         super.updateSizeFromText();
      }
   }

}
