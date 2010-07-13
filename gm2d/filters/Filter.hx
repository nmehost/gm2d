package gm2d.filters;

class Filter
{
   static public function set(obj:gm2d.display.DisplayObject,
                              filter:BitmapFilter)
   {
      if (filter==null)
         obj.filters = null;
      else
      {
         var f = new Array<BitmapFilter>();
         f.push(filter);
         obj.filters = f;
      }
   }
}
