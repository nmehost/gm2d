package gm2d;

import gm2d.display.DisplayObjectContainer;

class Lib
{
   public static var current(getCurrent,null) : DisplayObjectContainer;
   public static var debug:Bool = false;
   public static var isOpenGL(getIsOpenGL,null):Bool;


   static function getCurrent() : DisplayObjectContainer
   {
   #if flash
      return flash.Lib.current;
   #else
      return nme.Lib.current;
   #end
   }

   static function getIsOpenGL() { return false; }
}

