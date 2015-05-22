package gm2d.tween;

class Timeline
{
   var time:Float;
   var tweens:Array<Tween>;

   public function new( )
   {
      tweens = new Array<Tween>();
      time = 0;
   }
   public function clearAll()
   {
      tweens = new Array<Tween>();
   }
   public function remove(inName:String)
   {
      for(i in 0...tweens.length)
      {
         var tween = tweens[i];
         if (tween.name==inName)
         {
            tweens.splice(i,1);
            return;
         }
      }
   }
   public function update(inDT:Float)
   {
      time += inDT;
      if (tweens.length>0)
      {
         var curr_tweens = tweens;
         tweens = new Array<Tween>();
         for(tween in curr_tweens)
         {
            if (tween.t1>time)
            {
               tween.onUpdate( (time-tween.t0)/(tween.t1-tween.t0) );
               tweens.push(tween);
            }
            else
            {
               tween.onUpdate(1.0);
               if (tween.onComplete!=null)
                  tween.onComplete();
            }
         }
      }
   }


   public function createTween(inName:String,inVal0:Float,inVal1:Float,
                     inSeconds:Float,
                     inOnUpdate:Float->Void,
                     ?inOnComplete:Void->Void,
                     ?inEasing:Float->Float )
   {
      var tween = new Tween(inName, time, time+inSeconds, null, inOnComplete);
      if (inEasing==null)
          tween.onUpdate = function(x:Float) inOnUpdate( inVal0 + x*(inVal1-inVal0) );
      else
          tween.onUpdate = function(x:Float) inOnUpdate( inVal0 + inEasing(x)*(inVal1-inVal0) );
      tweens.push(tween);
   }
}


