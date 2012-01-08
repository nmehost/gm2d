package gm2d.tween;

class Tween
{
   public var name:String;
   public var t0:Float;
   public var t1:Float;
   public var onComplete:Void->Void;
   public var onUpdate:Float->Void;

   public function new(inName:String,inT0:Float,inT1:Float,?inOnUpdate:Float->Void,?inOnComplete:Void->Void)
   {
      name = inName;
      t0 = inT0;
      t1 = inT1;
      onUpdate = inOnUpdate;
      onComplete = inOnComplete;
   }

   public static function LINEAR(x:Float) : Float { return x; }
   public static function DECELERATE(x:Float) : Float { return 1-(x-1)*(x-1); }
}

