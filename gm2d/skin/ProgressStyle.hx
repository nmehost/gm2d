package gm2d.skin;

enum ProgressStyle
{
   // lineWidth/radius are logical units - resolved live (skin.toPixels) by the widget that
   // consumes this style, the same convention as attribSet's padding/minSize/etc. outline is
   // resolved live via skin.resolveLineColour, fill/empty via skin.resolveFillColour.
   ProgressRoundRect( outline:LineStyle, fill:FillStyle, empty:FillStyle, lineWidth:Float, radius:Float );
   ProgressRoundRectBall( outline:LineStyle, fill:FillStyle, empty:FillStyle, lineWidth:Float, radius:Float );
}



