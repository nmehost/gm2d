package gm2d.svg;


class TSpan
{
   public var text:String;
   public var x:Null<Float>;
   public var y:Null<Float>;

   public function new(el:Xml)
   {
      if (el.exists("x"))
         x = Std.parseFloat( el.get("x") );
      if (el.exists("y"))
         y = Std.parseFloat( el.get("y") );
      var textChild = el.firstChild();
      text = textChild==null ? "" : textChild.nodeValue;
   }
}


