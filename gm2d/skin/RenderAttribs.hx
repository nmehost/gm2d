package gm2d.skin;

class RenderAttribs
{
   var attribs:Map<String,Dynamic>;
   var states:Array<String>;
   var lineage:Array<String>;

   public function new(inLineage:Array<String>, inStateMatch:Array<String>, inAttribs:Dynamic)
   {
      states = inStateMatch;
      lineage = inLineage;
      attribs = new Map<String,Dynamic>();
      for(key in Reflect.fields(inAttribs))
         attribs.set(key, Reflect.field(inAttribs,key));
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

