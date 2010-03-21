package gm2d;

class Lib
{

  public static function boot( inOnLoaded:Void->Void,inWidth:Int=480, inHeight:Int=320,
           inFrameRate:Float = 60.0,  inColour:Int = 0xffffff,
           inFlags:Int = 0x0f, inTitle:String = "GM2D", inIcon : String="")
	{

   #if flash
     inOnLoaded();
   #else
     nme.Lib.create(inOnLoaded,inWidth,inHeight,inFrameRate,inColour,
	       (nme.Lib.HARDWARE) | nme.Lib.RESIZABLE);
   #end
	}
}

