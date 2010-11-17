package gm2d.ui;

import gm2d.display.DisplayObject;


class Pane
{
   public static var POS_OVER = 0;

   public static var RESIZABLE = 0x0001;


   var mTitle:String;
   var mObject:DisplayObject;
   var mFlags:Int;
   var mMinSizeX:Float;
   var mMinSizeY:Float;
   var mBestSizeX:Float;
   var mBestSizeY:Float;

   public function new(inObj:DisplayObject, inTitle:String, inFlags:Int)
   {
       mObject = inObj;
       mTitle = inTitle;
       mFlags = inFlags;
       mBestSizeX = mObject.width;
       mBestSizeY = mObject.height;
       mMinSizeX = 0;
       mMinSizeY = 0;
   }
}

