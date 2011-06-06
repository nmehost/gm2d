package gm2d.swf;

import gm2d.swf.Shape;
import gm2d.swf.MorphShape;
import gm2d.swf.Sprite;
import gm2d.swf.Bitmap;
import gm2d.swf.Font;
import gm2d.swf.StaticText;
import gm2d.swf.EditText;

enum Character
{
   charShape(inShape:Shape);
   charMorphShape(inMorphShape:MorphShape);
   charSprite(inSprite:Sprite);
   charBitmap(inBitmap:Bitmap);
   charFont(inFont:Font);
   charStaticText(inText:StaticText);
   charEditText(inText:EditText);
}
