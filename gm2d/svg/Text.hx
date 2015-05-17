package gm2d.svg;




class Text extends DisplayElement
{
   /*
   public var font_family:String;
   public var font_size:Float;
   public var kerning:Float;
   public var letter_spacing:Float;
   */

   public var text:String;


   override public function asText() : Text return this;
   override function toString():String return "Text(" + text + ")";

}

