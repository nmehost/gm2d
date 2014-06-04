package gm2d.skin;

class RenderAttribs
{
   public var attribs:Map<String,Dynamic>;
   public var state:Null<Int>;
   public var line:String;

   public function new(inLine:String, inStateMatch:Null<Int>, inAttribs:Dynamic)
   {
      state = inStateMatch;
      line = inLine;
      attribs = new Map<String,Dynamic>();
      for(key in Reflect.fields(inAttribs))
         attribs.set(key, Reflect.field(inAttribs,key));
   }

   public function matches(inLineage:Array<String>, inState:Int)
   {
      if (state!=null)
      {
         if (state==0 && inState!=0)
            return false;
         if ( (state & inState) == 0)
            return false;
      }

      if (line==null || inLineage==null)
         return true;
      for(l in inLineage)
         if (l==line)
             return true;
      return false;
   }

   public function merge(map: Map<String, Dynamic>)
   {
      for(key in attribs.keys())
         map.set(key, attribs.get(key));
   }

   static function mergeAttribMap(map: Map<String, Dynamic>, inAttribs:Dynamic) : Map<String, Dynamic>
   {
      if (map==null)
          map = new  Map<String, Dynamic>();
      for(key in Reflect.fields(inAttribs))
         if (!map.exists(key))
         {
            map.set(key, Reflect.field(inAttribs,key));
         }
      return map;
   }


}

