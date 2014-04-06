package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Shape;
import nme.display.Sprite;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.skin.ButtonRenderer;
import gm2d.ui.WidgetState;


class CheckButtons extends ChoiceButtons
{
   var onCheck:Bool->Void;
   public function new(inValue:Bool, inCheck:Bool->Void)
   {
      onCheck = inCheck;
      super(onButton);

      var shape = new Shape();
      var gfx = shape.graphics;
      gfx.lineStyle(4,0x00ff00);
      gfx.moveTo(4,16);
      gfx.lineTo(8,20);
      gfx.lineTo(20,8);
      var bmp = new BitmapData(24,24,true,gm2d.RGB.CLEAR );
      bmp.draw(shape);
      add(new Button(new Bitmap(bmp),null,["ToggleButton"]),"on");

      gfx.clear();
      gfx.lineStyle(4,0xff0000);
      gfx.moveTo(8,8);
      gfx.lineTo(16,16);
      gfx.moveTo(8,16);
      gfx.lineTo(16,8);
      var bmp = new BitmapData(24,24,true,gm2d.RGB.CLEAR );
      bmp.draw(shape);
      add(new Button(new Bitmap(bmp),null,["ToggleButton"]),"off");

      setChecked(inValue);
      build();
   }
   function onButton(inKey:String) { if (onCheck!=null) onCheck(inKey=="on"); }

   public function setChecked(inCheck:Bool)
   {
      setValue(inCheck?"on":"off");
   }
}

