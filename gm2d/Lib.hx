package gm2d;

import nme.display.DisplayObjectContainer;

class Lib
{
   public static var current(get_current,null) : DisplayObjectContainer;
   public static var debug:Bool = false;
   public static var isOpenGL(get_isOpenGL,null):Bool;


   static function get_current() : DisplayObjectContainer
   {
      #if flash
      return flash.Lib.current;
      #else
      return nme.Lib.current;
      #end
   }

   static function get_isOpenGL()
   {
      #if flash
      return false;
      #else
      return nme.Lib.stage.isOpenGL;
      #end
   }
}

