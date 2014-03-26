package gm2d.ui;

import nme.text.TextField;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import gm2d.RGBHSV;
import nme.text.TextFieldAutoSize;


class RGBBox extends Widget
{
   var textField:TextField;
   var mColour:RGBHSV;
   var updateLockout:Int;
   public var onColourChange:RGBHSV->Int->Void;
   public var onDialogCreated:RGBDialog->Void;
   var mShowAlpha:Bool;
   var rgbDialog:RGBDialog;

   public function new(inColour:RGBHSV,inShowAlpha:Bool,inShouldShowPopup=false,?inOnColour:RGBHSV->Int->Void)
   {
      super();
      mShowAlpha = inShowAlpha;
      onColourChange = inOnColour;
      mColour = inColour.clone();
      updateLockout = 0;
      mLayout = new DisplayLayout(this);
      getLayout().setMinSize(72,28);

      var fmt = new nme.text.TextFormat();
      fmt.align = nme.text.TextFormatAlign.CENTER;

      textField = new TextField( );
      textField.border = true;
      textField.defaultTextFormat = fmt;
      textField.borderColor = 0x000000;
      textField.background = true;
      addChild(textField);

      if (inShouldShowPopup)
         textField.addEventListener(MouseEvent.CLICK, function(_) showDialog() );

      textField.text = "0x00000000";
      build();
   }

   public function showDialog( )
   {
      var isNew = false;
      if (rgbDialog==null)
      {
         isNew = true;
         rgbDialog = new RGBDialog(mColour, function(colour,phase) {
            if (onColourChange!=null && updateLockout==0)
               onColourChange(colour.clone(),phase);
            setColour(colour);
            } );
         rgbDialog.onClose = function() rgbDialog = null;
         if (onDialogCreated!=null)
            onDialogCreated(rgbDialog);
      }
      Game.doShowDialog(rgbDialog,isNew);
   }

   public function getColour():RGBHSV
   {
      return mColour.clone();
   }

   public function setColour(inCol:RGBHSV)
   {
      updateLockout++;
      var draw =  (inCol.compare(mColour)!=0 || (inCol.a!=mColour.a && mShowAlpha) );
      mColour = inCol.clone();
      if (rgbDialog!=null)
         rgbDialog.setColour(inCol);
      if (draw)
         redraw();
      updateLockout--;
   }

   override function redraw()
   {
      textField.width = mRect.width;
      textField.height = mRect.height;
      textField.backgroundColor = mColour.getRGB();
      textField.textColor = mColour.v > 128 ? 0x000000 : 0xffffff;
      updateLockout++;
      if (mShowAlpha)
         textField.text = StringTools.hex(Std.int(mColour.a*255),2) + StringTools.hex(mColour.getRGB(),6);
      else
         textField.text = StringTools.hex(mColour.getRGB(),6);
      updateLockout--;
   }

}


