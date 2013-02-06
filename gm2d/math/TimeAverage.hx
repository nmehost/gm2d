package gm2d.math;

class TimedValue
{
   public var time:Float;
   public var value:Float;
   public var weight:Float;

   public function new(inTime:Float,inVal:Float,inWeight:Float)
   {
      time = inTime;
      value = inVal;
      weight = inWeight;
   }
}

class TimeAverage
{
   public var window:Float;
   public var samples:Array<TimedValue>;
   public var mean(get_mean,null):Float;
   public var isValid(get_isValid,null):Bool;

   public function new(inWindow:Float)
   {
      samples = [];
      window = inWindow;
   }
   public function add(inValue:Float,inWeight:Float=1.0)
   {
      var now = gm2d.Timer.stamp();
      samples.push(new TimedValue(now,inValue,inWeight));
      removeOld(now-window);
   }
   public function clear()
   {
      samples = [];
   }
   public function get_isValid() : Bool { return samples.length>0; }
   function removeOld(inTime:Float)
   {
      var keepFirst = 0;
      while(keepFirst<samples.length-1)
      {
         if (samples[keepFirst].time>inTime)
            break;
         keepFirst++;
      }
      if (keepFirst>0)
         samples.splice(0,keepFirst);
   }
   public function get_mean() : Float
   {
      if (samples.length<1)
         return 0.0;
      var now = gm2d.Timer.stamp();
      var total = 0.0;
      var total_w = 0.0;
      for(s in samples)
      {
         total += s.value * s.weight;
         total_w += s.weight;
      }
      return total/total_w;
   }
}

