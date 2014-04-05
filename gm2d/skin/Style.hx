package gm2d.skin;

import gm2d.ui.Widget;

enum Style
{
   StyleNone;
   StyleShape( fill:FillStyle, line:LineStyle, shape:ShapeStyle );
   StyleCustom( render:Widget->Void );
}

