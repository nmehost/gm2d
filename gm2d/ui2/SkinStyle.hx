package gm2d.ui2;

class SkinStyle
{
   public var attribs(default,null):Map<String,Dynamic>;

   public var widget(default,null):String;
   public var styleName(default,null):String;
   public var id(default,null):String;
   public var idMatch(default,null):EReg;
   public var active(default,null):Active;
   public var enabled(default,null):Enabled;
   public var down(default,null):Null<Bool>;
   public var contextMatch(default,null):EReg;

   public function new( filter:StyleFilter, inAttribs:Map<String,Dynamic> )
   {
      attribs = inAttribs;

      if (filter!=null)
      {
         widget = filter.widget;
         styleName = filter.styleName;
         id = filter.id;
         idMatch = filter.idMatch;
         active = filter.active;
         enabled = filter.enabled;
         down = filter.down;
         contextMatch = filter.contextMatch;
      }
   }
   public function toString() : String
   {
      return attribs + "";
   }
}

