package gm2d.ui;

import nme.text.TextField;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import gm2d.RGBHSV;
import gm2d.skin.Skin;
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

   public function new(inColour:RGBHSV,inShowAlpha:Bool,inShouldShowPopup=false,?inOnColour:RGBHSV->Int->Void, ?inAttribs:{ })
   {
      super(null,inAttribs);
      mShowAlpha = inShowAlpha;
      onColourChange = inOnColour;
      mColour = inColour==null ? new RGBHSV( ) : inColour.clone();
      updateLockout = 0;

      var fmt = new nme.text.TextFormat();
      fmt.align = nme.text.TextFormatAlign.CENTER;
      fmt.size = Skin.scale(14);

      textField = new TextField( );
      textField.text = "FFFFFFFF";
      mRenderer.renderLabel(textField);
      textField.border = false;
      textField.background = false;
      // Todo - enter text
      //textField.selectable = true;
      var fmt = textField.defaultTextFormat;
      fmt.align = "center";
      textField.defaultTextFormat = fmt;
      addChild(textField);

      var textLayout = new TextLayout(textField).setAlignment(Layout.AlignCenterY|Layout.AlignStretch);
      textLayout.setMinSize( textField.textWidth, textField.textHeight*1.2 );
      setItemLayout(textLayout);

      if (inShouldShowPopup)
         addEventListener(MouseEvent.CLICK, function(_) showDialog() );

      //build();
   }

   public function setRgba(rgb:Int, a:Float)
   {
      mColour = new RGBHSV(rgb,a);
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
      //Game.doShowDialog(rgbDialog,isNew);
      Game.popup(rgbDialog,rgbDialog.onClose);
   }

   public function getColour():RGBHSV
   {
      return mColour.clone();
   }

   override public function set(data:Dynamic)
   {
      if (Std.isOfType(data,String) && data!="")
         setColour( RGBHSV.fromHex(data,mShowAlpha) );
      else if (Std.isOfType(data,RGBHSV) )
         setColour( data );
      else if (Std.isOfType(data,Int) )
      {
         var col:Int = data;
         setColour( new RGBHSV(col,mShowAlpha ? (col>>24)/255.0 : 1.0 ) );
      }
   }

   override public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
      {
         var t = Reflect.field(inValue,name);
         if (Std.isOfType(t,Int))
            Reflect.setField(inValue, name, mColour.getRGBA() );
         else if (Std.isOfType(t,String))
            Reflect.setField(inValue, name, mColour.getHex() );
         else
            Reflect.setField(inValue, name, mColour.clone() );
      }
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
      clearChrome();
      var gfx = mChrome.graphics;
      gfx.lineStyle(0,0x000000);
      gfx.beginFill(mColour.getRGB());
      gfx.drawRect( mRect.x, mRect.y, mRect.width, mRect.height );
      onWidgetDrawn();

      textField.textColor = mColour.v > 128 ? 0x000000 : 0xffffff;
      updateLockout++;
      if (mShowAlpha)
         textField.text = StringTools.hex(Std.int(mColour.a*255),2) + StringTools.hex(mColour.getRGB(),6);
      else
         textField.text = StringTools.hex(mColour.getRGB(),6);
      updateLockout--;
   }

}


