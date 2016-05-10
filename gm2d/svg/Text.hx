package gm2d.svg;
import Xml;


class Text extends DisplayElement
{
   /*
   public var font_family:String;
   public var font_size:Float;
   public var kerning:Float;
   public var letter_spacing:Float;
   */

   public var text:String;
   public var tspans:Array<TSpan>;

   public function new()
   {
      super();
      tspans = [];
   }

   public function addTSpan(el:Xml)
   {
      tspans.push( new TSpan(el) );
   }

   override public function asText() : Text return this;
   override function toString():String return "Text(" + text + ")";

}

