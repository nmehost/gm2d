package gm2d.ui;

import nme.text.TextField;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import gm2d.ui.ColourControl;
import gm2d.RGBHSV;
import nme.text.TextFieldAutoSize;


class RGBBox extends Widget
{
   var textLabel:TextLabel;
   var mColour:RGBHSV;
   var updateLockout:Int;
   public var onColourChange:RGBHSV->Int->Void;
   public var onDialogCreated:RGBDialog->Void;
   var mShowAlpha:Bool;
   var rgbDialog:RGBDialog;
   var shouldShowPopup:Bool;
   var swatchSet:SwatchSet;

   public function new(inColour:RGBHSV,inShowAlpha:Bool,inShouldShowPopup=false,?inOnColour:RGBHSV->Int->Void, ?swatchSet:SwatchSet, ?inAttribs:Attribs)
   {
      super(inAttribs);
      mShowAlpha = inShowAlpha;
      onColourChange = inOnColour;
      mColour = inColour==null ? new RGBHSV( ) : inColour.clone();
      updateLockout = 0;
      this.swatchSet = swatchSet;

      var attribs:Attribs = {
           alternateText:"WWWWWWWW",
           textAlign:"center",
           //fill : FillSolid(0xff00ff,1),
           fill : FillNone,
         };
      if (inShouldShowPopup)
      {
         attribs.onEnter = showDialog;
         attribs.wantsFocus = true;
         attribs.shape = ShapeRect;
         attribs.stateCurrent = {
            line: LineHighlight,
         };
      }
      if (inShouldShowPopup)
         textLabel = new TextLabel("FFFFFFFF", attribs);
      else
      {
         textLabel = new TextInput("FFFFFFFF",
         function(s:String, phase:Int) {
            if (updateLockout==0 && ((s.length==6) || (s.length==8)) )
            {
               updateLockout++;
               var col = RGBHSV.fromHex("0x" + s,s.length==8);
               setColour(col);
               if (onColourChange!=null)
                  onColourChange(col,phase);
               updateLockout--;
            }
         },
         attribs);
      }
      addWidget(textLabel);
   }


   public function setRgba(rgb:Int, a:Float)
   {
      setColour(new RGBHSV(rgb,a));
   }

   public function showDialog( )
   {
      var isNew = false;
      if (rgbDialog==null || rgbDialog.skin!=skin)
      {
         isNew = true;
         rgbDialog = new RGBDialog(mColour, function(colour,phase) {
            if (onColourChange!=null && updateLockout==0)
               onColourChange(colour.clone(),phase);
            setColour(colour);
            }, swatchSet );
         rgbDialog.onClose = function() rgbDialog = null;
         rgbDialog.setSkin(skin);
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
         setColour( RGBHSV.fromHex(data,data.length==8) );
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
      var draw =  (inCol.compare(mColour)!=0 || (inCol.a!=mColour.a && mShowAlpha) );
      mColour = inCol.clone();
      if (rgbDialog!=null)
         rgbDialog.setColour(inCol);
      if (draw)
         redraw();
   }

   override function redraw()
   {
      super.redraw();
      //clearChrome();
      var gfx = mChrome.graphics;
      gfx.lineStyle(0,0x000000);

      gfx.beginFill( isCurrent ? 0x4040ff : mColour.getRGB());
      gfx.drawRect( mRect.x+0.5, mRect.y+0.5, mRect.width, mRect.height );
      onWidgetDrawn();

      var textField = textLabel.getLabel();
      textField.textColor = mColour.v > 128 ? 0x000000 : 0xffffff;
      if (updateLockout==0)
      {
         updateLockout++;
         if (mShowAlpha)
         {
            var a = Std.int(mColour.a*255);
            if (a<0) a = 0;
            else if (a>255) a = 255;
            var aTxt = StringTools.hex(a,2);
            var cTxt = StringTools.hex(mColour.getRGB(),6);
            textField.text = aTxt+ cTxt;
         }
         else
            textField.text = StringTools.hex(mColour.getRGB(),6);
         updateLockout--;
      }
   }

}


