package gm2d.skin;

import gm2d.ui.Widget;

enum Style
{
   StyleNone;
   StyleRect;
   StyleUnderlineRect;
   StyleRoundRect;
   StyleRoundRectRad(inRad:Float);
   StyleCustom( renderer:Widget->Void );
}

