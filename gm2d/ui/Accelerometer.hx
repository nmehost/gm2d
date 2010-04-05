package gm2d.ui;

#if flash

class Accelerometer
{
   public static function get() : Acceleration { return null; }
}

#else
typedef Accelerometer = nme.ui.Accelerometer;
#end
