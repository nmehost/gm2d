package gm2d.ui2;

import nme.text.TextFormat;


class SkinFont
{
   public var size(default,null):Float;
   var textFormat:TextFormat;

   public function new(inName:String, inSize:Float, inBold:Bool)
   {
      size = inSize;
      textFormat = new TextFormat();
      textFormat.font = inName;
      textFormat.bold = inBold;
   }

   public function getFormat()
   {
      textFormat.size = Std.int(size * Skin.uiScale);
      return textFormat;
   }
}

