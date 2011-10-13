package gm2d.ui;

import gm2d.text.TextField;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;


class ComboList extends Window
{
   var mList:ListControl;
   var mCombo:ComboBox;
   var mOptions:Array<String>;

   public function new(inParent:ComboBox, inW:Float, inOptions:Array<String>)
   {
      super();
      mCombo = inParent;
      mList = new ListControl(inW);
      mOptions = inOptions;
      if (mOptions.length==0)
         mOptions.push("");

      for(o in mOptions)
         mList.addText(o,false);
      addChild(mList);
      var gfx = graphics;
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(-0.5,-0.5,inW+2, mList.height+2);
      addEventListener( gm2d.events.MouseEvent.CLICK, onClick);
   }

   override function windowMouseMove(inEvent:MouseEvent)
   {
      mList.selectByY(inEvent.localY);
   }

   public function onClick(inEvent)
   {
      var idx = mList.selectByY(inEvent.localY);
      if (idx>=0)
         mCombo.setText(mOptions[idx]);
      gm2d.Game.closePopup();
   }



   override public function destroy()
   {
      super.destroy();
   }
}



class ComboBox extends Control
{
   var mText:TextField;
   var mButtonX:Float;
   var mWidth:Float;
   var mOptions:Array<String>;
   static var mBMP:BitmapData;

   public function new(inVal="", ?inOptions:Array<String>)
   {
       super();
       mText = new TextField();
       mText.defaultTextFormat = Panel.labelFormat;
       mText.text = inVal;
       mText.x = 0.5;
       mText.y = 0.5;
       mText.height = 21;
       mText.type = gm2d.text.TextFieldType.INPUT;
 
       if (mBMP==null)
       {
          mBMP = new BitmapData(22,22);
          var shape = new gm2d.display.Shape();
          var gfx = shape.graphics;
          gfx.beginFill(0xffffff);
          gfx.drawRect(-2,-2,28,28);

          gfx.beginFill(0xf0f0f0);
          gfx.lineStyle(1,0x808080);
          gfx.drawRoundRect(0.5,0.5,21,21,3);
          gfx.lineStyle();

          gfx.beginFill(0x000000);
          gfx.moveTo(8,8);
          gfx.lineTo(8,8);
          gfx.lineTo(16,8);
          gfx.lineTo(12,14);
          gfx.lineTo(8,8);
          mBMP.draw(shape);
       }
       mOptions = inOptions==null ? [] : inOptions.copy();
       addChild(mText);
       var me = this;
       addEventListener(MouseEvent.CLICK, function(ev)  if (ev.localX > me.mButtonX) me.doPopup()  );
   }

   function doPopup()
   {
      var pop = new ComboList(this, mWidth, mOptions);
      var pos = this.localToGlobal( new gm2d.geom.Point(0,0) );
      gm2d.Game.popup(pop,pos.x,pos.y+22);
   }

   public function setText(inText:String)
   {
       mText.text = inText;
       mText.height = 100;
   }

   public override function layout(inW:Float, inH:Float)
   {
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xf0f0ff);
       gfx.drawRect(0.5,0.5,inW-1,23);
       gfx.lineStyle();
       var mtx = new gm2d.geom.Matrix();
       mtx.tx = inW-mBMP.width-1;
       mtx.ty = 1;
       gfx.beginBitmapFill(mBMP,mtx);
       mButtonX = inW-mBMP.width-1+0.5;
       mWidth = inW;
       gfx.drawRect(mButtonX,1.5,mBMP.width,mBMP.height);
       mText.width = inW - mBMP.width - 2;
       mText.y =  (mBMP.height - 2 - mText.textHeight)/2;
       mText.height =  mBMP.height-mText.y;
   }

}


