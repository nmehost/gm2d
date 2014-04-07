package gm2d.skin;

import gm2d.ui.Widget;

enum Style
{
   StyleNone;
   StyleRect;
   StyleRoundRect;
   StyleRoundRectRad(inRad:Float);
   StyleCustom( render:Widget->Void );
}

