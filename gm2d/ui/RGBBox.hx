package gm2d.ui;

import gm2d.text.TextField;
import gm2d.ui.Layout;
import gm2d.events.MouseEvent;
import gm2d.RGBHSV;

class RGBDialog extends Dialog
{
   public function new(inRGB:RGBHSV)
   {
      var cc = new ColourControl(inRGB.getRGB(), 1.0);

      var pane = new Pane(cc, "Select Colour", Dock.RESIZABLE);
      pane.itemLayout = cc.getLayout();
      pane.setMinSize(400,400);
      super(pane);
   }
}


class RGBBox extends Widget
{
   var textField:TextField;
   var mWidth:Float;
   var mHeight:Float;
   var mColour:RGBHSV;
   var updateLockout:Int;
   public var showPopup:Bool;
   var mShowAlpha:Bool;

   public function new(inColour:RGBHSV,inShowAlpha:Bool,inShowPopup=false)
   {
      super();
      mShowAlpha = inShowAlpha;
      mColour = inColour.clone();
      mWidth = mHeight = 32;
      updateLockout = 0;
      getLayout().setMinSize(20,32);

      var fmt = new nme.text.TextFormat();
      fmt.align = nme.text.TextFormatAlign.CENTER;

      textField = new TextField( );
      textField.border = true;
      textField.defaultTextFormat = fmt;
      textField.borderColor = 0x000000;
      textField.background = true;
      addChild(textField);

      if (inShowPopup)
      {
         textField.addEventListener(MouseEvent.CLICK, onShowPopup);
      }
      redraw();
   }

   public function onShowPopup(ev:MouseEvent)
   {
      var dlg = new RGBDialog(mColour);
      Game.doShowDialog(dlg,true);
   }

   public function getColour():RGBHSV
   {
      return mColour.clone();
   }

   public function setColour(inCol:RGBHSV)
   {
      var draw =  (inCol.compare(mColour)!=0 || (inCol.a!=mColour.a && mShowAlpha) );
      mColour = inCol.clone();
      if (draw)
         redraw();
   }

   function redraw()
   {
      textField.width = mWidth;
      textField.height = mHeight;
      textField.backgroundColor = mColour.getRGB();
      textField.textColor = mColour.v > 128 ? 0x000000 : 0xffffff;
      updateLockout++;
      if (mShowAlpha)
         textField.text = StringTools.hex(Std.int(mColour.a*255),2) + StringTools.hex(mColour.getRGB(),6);
      else
         textField.text = StringTools.hex(mColour.getRGB(),6);
      updateLockout--;
   }

   public override function layout(inWidth:Float,inHeight:Float)
   {
      mWidth = inWidth;
      mHeight = inHeight;
      redraw();
   }
}


