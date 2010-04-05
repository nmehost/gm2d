package gm2d.ui;

typedef Acceleration = 
#if flash
{
   x : Float,
   y : Float,
   z : Float 
}
#else
nme.ui.Acceleration;
#end
