package gm2d.skin;

enum LineStyle
{
   LineNone;
   LineBorder;
   LineTrim;
   LineHighlight;
   LineSolid( width:Float, rgb:Int, a:Float );
   // Like LineSolid, but the colour stays deferred - resolved live against the skin at draw
   // time via a named FillStyle role, instead of being baked in when the enum value is created.
   LineSolidFill( width:Float, fill:FillStyle, a:Float );
}


