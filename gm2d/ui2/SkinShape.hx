package gm2d.ui2;

import nme.display.Graphics;
import nme.geom.Rectangle;


enum SkinShape
{
   SS_RECT;
   SS_ROUND_RECT(rad:Float);
   SS_CUSTOM(render:Graphics->Skin->Rectangle->Void);
}


