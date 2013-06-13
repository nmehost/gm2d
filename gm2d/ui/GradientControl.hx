package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.BitmapData;
import gm2d.display.Shape;
import gm2d.display.Sprite;
import gm2d.display.Bitmap;
import gm2d.display.SpreadMethod;
import gm2d.geom.Rectangle;
import gm2d.Gradient;
import gm2d.text.TextField;
import gm2d.ui.MouseWatcher;
import gm2d.ui.Layout;
import gm2d.ui.HitBoxes;
import gm2d.display.GradientType;
import gm2d.InterpolationMethod;
import gm2d.geom.Matrix;
import gm2d.geom.Point;
import gm2d.events.MouseEvent;
import gm2d.skin.Skin;
import gm2d.skin.ButtonRenderer;
import gm2d.RGBHSV;


class GradSwatchBox extends Widget
{
   var swatch:GradSwatch;
   var control:GradientControl;
   public function new(inControl:GradientControl, inSwatch:GradSwatch, inSize:Int)
   {
      super();
      control = inControl;
      swatch = inSwatch;
      var gfx = graphics;
      gfx.beginBitmapFill(swatch.bitmapData);
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(0.5,0.5,inSize,inSize);
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) inControl.setGradient(inSwatch.gradient) );
   }
}

class GradSwatch
{
   public var gradient:Gradient;
   public var bitmapData:BitmapData;

   public function new(index:Int, of:Int)
   {
      var cycle = of>>1;
      var idx = index % cycle;
      var colour0 : RGBHSV = null;
      gradient = new Gradient();
      if (idx==0)
         colour0 = new RGBHSV( 0xffffff);
      else
      {
         idx--;
         cycle--;
         colour0 = new RGBHSV(0xffffff);
         colour0.setHSV( idx/cycle * 360, 1.0, (index<of/2) ? 255 : 128 );
      }
      gradient.addStop(colour0,0);
      var colour1 = index*2>of ? new RGBHSV(0xffffff, 1) :
                                new RGBHSV(0x000000, index>0 ? 1 : 0) ;
      gradient.addStop(colour1,1);

      bitmapData = new BitmapData(32,32,true,gm2d.RGB.WHITE);
      setData();
   }

   function setData()
   {
      var s = new Shape();
      var gfx = s.graphics;
      gradient.beginFillBox(gfx, 0,0,32*0.707,32*0.707,Math.PI*0.25);
      gfx.drawRect(0,0,32,32);
      bitmapData.draw(s);
   }
}



class GradientControl extends Widget
{
   var updateLockout:Int;
   public var onChange:Gradient->Int->Void;
   public var gradBox:Sprite;
   var mWidth:Float;
   var mHeight:Float;
   var colourBox:RGBBox;
   var position:NumericInput;
   var stopX0:Float;
   var stopW:Float;
   var spread:ChoiceButtons;
   var interp:ChoiceButtons;
   var type:ChoiceButtons;
   var focal:NumericInput;
   var positionMarker:Bitmap;

   var gradient:Gradient;
   var currentId:Int;

   static var spreads = [ SpreadMethod.PAD, SpreadMethod.REFLECT, SpreadMethod.REPEAT];
   static var types = [ GradientType.LINEAR, GradientType.RADIAL ];
   static var interps = [ InterpolationMethod.LINEAR_RGB, InterpolationMethod.RGB, InterpolationMethod.STEP ];

   public static var createdBmps = false;
   public static var bitmaps = new haxe.ds.StringMap<BitmapData>();

   public function new(inOnChange:Gradient->Int->Void)
   {
      super();

      onChange = inOnChange;
      updateLockout = 1;
      stopX0 = 0;
      stopW = 1;

      gradBox = new Sprite();
      mWidth = mHeight = 32;
      addChild(gradBox);
      var gradLayout = new DisplayLayout(gradBox,Layout.AlignCenterY|Layout.AlignStretch,32,64);
      gradLayout.setPadding(8,0);
      gradLayout.onLayout = renderGradBox;
      gradBox.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);

      var stopControls = new GridLayout(1);
      colourBox = new RGBBox(new RGBHSV(0xff00ff,1), false, true, onGradColour);
      colourBox.onDialogCreated = onColourDialog;
      addChild(colourBox);
      stopControls.add(colourBox.getLayout().setMinSize(64,28));

      position = new NumericInput(0.0, false, 0, 1, 0.004, onPosition);
      addChild(position);
      position.setTextWidth(64);
      stopControls.add(position.getLayout());

      var skin = Skin.current;
      var addRemoveLayout = new GridLayout(2,0);
      addRemoveLayout.setSpacing(0,0);
      var addStop = Button.BMPButton(skin.getButtonBitmapData(MiniButton.ADD,0),0,0,onAddStop);
      addChild(addStop);
      addStop.getItemLayout().setBorders(5,5,5,5);
      addRemoveLayout.add(addStop.getLayout().setBorders(5,5,5,5));
      var removeStop = Button.BMPButton(skin.getButtonBitmapData(MiniButton.REMOVE,0),0,0,onRemoveStop);
      addChild(removeStop);
      removeStop.getItemLayout().setBorders(5,5,5,5);
      addRemoveLayout.add(removeStop.getLayout().setBorders(5,5,5,5));
      stopControls.add(addRemoveLayout);
      stopControls.setSpacing(4,4);

      var controls = new GridLayout(2,0);
      controls.add(stopControls);
      controls.add(gradLayout);
      controls.setColStretch(1,1);
      controls.setAlignment(Layout.AlignStretch);

      var swatches = new GridLayout(10);
      swatches.setSpacing(4,4);
      for(i in 0...20)
      {
         var swatch = new GradSwatch(i,20);
         var box = new GradSwatchBox(this,swatch,16);
         addChild(box);
         swatches.add(box.getLayout());
      }

      if (!createdBmps)
         createBmps();
      var properties = new GridLayout(4,0);

      properties.add( addLabel("Spread") );
      spread = ChoiceButtons.create( onSpread, spreads, bitmaps );
      addChild(spread);
      properties.add( spread.getLayout() );

      properties.add( addLabel("Interp") );
      interp = ChoiceButtons.create( onInterp, interps, bitmaps );
      addChild(interp);
      properties.add( interp.getLayout() );


      properties.add( addLabel("Type") );
      type = ChoiceButtons.create( onType, types, bitmaps );
      addChild(type);
      properties.add( type.getLayout() );

      properties.add( addLabel("Focal") );
      focal = new NumericInput(0.0, false, 0, 1, 0.004);
      focal.setTextWidth(64);
      addChild(focal);
      properties.add( focal.getLayout() );

      var vstack = new GridLayout(1,0);
      vstack.add(swatches);
      vstack.add(controls);
      vstack.add(properties);
      vstack.setColStretch(0,1);
      vstack.setAlignment(Layout.AlignStretch).setSpacing(0,4);
      updateLockout = 0;

      mLayout = vstack;

      positionMarker = new Bitmap( bitmaps.get("positionMarker") );
      positionMarker.y = -5;
      gradBox.addChild(positionMarker);

      setGradient( gradient = (new GradSwatch(0,20)).gradient );
   }

   public function getGradient() { return gradient.clone(); }

   public function createButton(inData:BitmapData)
   {
      var button = Button.BitmapButton(inData,null, ButtonRenderer.simple() );
      return button;
   }

   public static function createBmps()
   {
      createdBmps = true;
      var s = new Shape();
      var gfx = s.graphics;

      var gradient = new gm2d.Gradient( );
      gradient.addStop( new RGBHSV(0x005580,1), 0);
      gradient.addStop( new RGBHSV(0x508080,1), 0.5);
      gradient.addStop( new RGBHSV(0xa0b0b0,1), 1);
      var matrix = new Matrix();
      var size = 24;
      matrix.createGradientBox(size*0.5,size,0,0,0);
 
      for(spread in spreads)
      {
         var key:String = spread + "";
         if (!bitmaps.exists(key))
         {
            gradient.spreadMethod = spread;
            gfx.clear();
            var bmp = new BitmapData(size,size);
            gfx.lineStyle(1,0x000000);
            gradient.beginFill(gfx,matrix);
            gfx.drawRect(0.5,0.5,size-1,size-1);
            bmp.draw(s);
            bitmaps.set(key,bmp);
         }
      }

      matrix.createGradientBox(size,size,0,0,0);
      gradient.spreadMethod = spreads[2];
      for(type in types)
      {
         var key:String = type + "";
         if (!bitmaps.exists(key))
         {
            gradient.type = type;
            gfx.clear();
            var bmp = new BitmapData(size,size);
            gfx.lineStyle(1,0x000000);
            gradient.beginFill(gfx,matrix);
            gfx.drawRect(0.5,0.5,size-1,size-1);
            bmp.draw(s);
            bitmaps.set(key,bmp);
         }
      }
      gradient.type = types[0];
      for(interp in interps)
      {
         var key:String = interp + "";
         if (!bitmaps.exists(key))
         {
            gradient.interpolationMethod = interp;
            gfx.clear();
            var bmp = new BitmapData(size,size);
            gfx.lineStyle(1,0x000000);
            gradient.beginFill(gfx,matrix);
            gfx.drawRect(0.5,0.5,size-1,size-1);
            bmp.draw(s);
            bitmaps.set(key,bmp);
         }
      }

      if (!bitmaps.exists("positionMarker"))
      {
         var h = 42;
         var bmp = new BitmapData(7,h,true, gm2d.RGB.CLEAR );
         gfx.clear();
         gfx.lineStyle(1,0x000000);
         gfx.beginFill(0xffffff);
         gfx.moveTo(0.5,0.5);
         gfx.lineTo(6.5,0.5);
         gfx.lineTo(3.5,3.5);
         gfx.lineTo(0.5,0.5);

         gfx.moveTo(0.5,h-1-0.5);
         gfx.lineTo(6.5,h-1-0.5);
         gfx.lineTo(3.5,h-1-3.5);
         gfx.lineTo(0.5,h-1-0.5);

         gfx.moveTo(3.5,3.5);
         gfx.lineTo(3.5,h-1-3.5);

         bmp.draw(s);
         bitmaps.set("positionMarker",bmp);
      }
   }

   function onGradientChange(inPhase:Int=Phase.ALL)
   {
      if (updateLockout==0  && onChange!=null)
      {
         updateLockout++;
         onChange(gradient.clone(),inPhase);
         updateLockout--;
      }
      render();
   }

   function onPosition(pos:Float,inPhase:Int)
   {
      if (currentId>=0 && currentId<gradient.stops.length)
      {
         currentId = gradient.setStopPosition(currentId,pos);
         onGradientChange(inPhase);
      }
   }

   function onSpread(inSpread:Int)
   {
      gradient.spreadMethod = spreads[inSpread];
      onGradientChange();
   }

   function onInterp(inInterp:Int)
   {
      gradient.interpolationMethod = interps[inInterp];
      onGradientChange();
   }

   function onType(inType:Int)
   {
      gradient.type = types[inType];
      onGradientChange();
   }


   public function addLabel(inText:String)
   {
      var label = new TextField();
      Skin.current.labelRenderer.styleLabel(label);
      label.text = inText;
      addChild(label);
      return new TextLayout(label);
   }

   function onColourDialog(dialog:RGBDialog)
   {
      dialog.shouldConsumeEvent = function(event:MouseEvent) return event.target!=gradBox;
   }

   public function onGradColour(inColour:RGBHSV,inPhase:Int)
   {
      if (currentId>=0 && currentId<gradient.stops.length)
      {
         gradient.stops[currentId].colour = inColour;
         onGradientChange(inPhase);
      }
   }

   public function setCurrentStop(stopId:Int)
   {
      currentId = stopId;
      var stop = gradient.stops[stopId];
      if (stop!=null)
      {
         colourBox.setColour( stop.colour );
         position.setValue( stop.position );
         render();
      }
   }

   function posFromMouse(ev:MouseEvent)
   {
      var localX = gradBox.globalToLocal( new Point(ev.stageX, ev.stageY) ).x;
      var pos = localX/mWidth;
      if (pos<0)
         pos = 0;
      if (pos>1)
         pos = 1;
      if (currentId>=0 && currentId<gradient.stops.length)
      {
        currentId = gradient.setStopPosition(currentId,pos);
        position.setValue( pos );
        onGradientChange();
      }
   }

   function onMouse(ev:MouseEvent)
   {
      if (ev.localY>32)
      {
         var stop = Std.int((ev.localX-stopX0)/stopW);
         if (stop>=0 && stop<gradient.stops.length)
         {
            if (stop==currentId)
               colourBox.showDialog();
            else
               setCurrentStop(stop);
         }
      }
      else
      {
         MouseWatcher.watchDrag(gradBox, ev.localX, ev.localY, posFromMouse );
         posFromMouse(ev);
      }
   }

   function onAddStop()
   {
      var pos = gradient.stops[currentId].position;
      var col = gradient.stops[currentId].colour;

      if (currentId+1 < gradient.stops.length )
         pos = (pos + gradient.stops[currentId+1].position) * 0.5;
      else if (pos<1.0)
         pos = 1.0;
      else if (currentId>0)
         pos = (pos + gradient.stops[currentId-1].position) * 0.5;
      else
         pos = 0;

      setCurrentStop( gradient.add( new GradStop(col, pos) ) );
      render();
   }
   function onRemoveStop()
   {
      if (currentId>=0 && currentId<gradient.stops.length && gradient.stops.length>1)
      {
         gradient.stops.splice(currentId,1);
         if (currentId>=gradient.stops.length)
            currentId--;
         var stop = gradient.stops[currentId];
         if (stop!=null)
         {
            colourBox.setColour( stop.colour );
            position.setValue( stop.position );
         }
         onGradientChange();
      }
   }

   function renderGradBox(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      mWidth = inW;
      mHeight = inH;
      render();
   }

   function render()
   {
      var gfx = gradBox.graphics;
      gfx.clear();
      gradient.beginFill(gfx);

      gfx.beginFill(0xffffff);
      gfx.drawRect(0,0,mWidth,32);
      gfx.beginFill(0x808080);
      var x = 0;
      var y = 0;
      while(x<mWidth)
      {
         var w = x+16.0;
         if (w>mWidth-1) w = mWidth-1;
         gfx.drawRect(x,y,w-x,16);
         x+=16;
         y=16-y;
      }
      gfx.lineStyle(1,0x000000);
      gradient.beginFillBox(gfx,0,0,mWidth,32,0,GradientType.LINEAR);
      gfx.drawRect(0,0,mWidth,32);

      stopW = Std.int(mWidth/gradient.stops.length);
      if (stopW>32)
         stopW = 32;
      stopX0 = Std.int((mWidth - stopW*gradient.stops.length) * 0.5) + 4.5;
      var x = stopX0;
      for(i in 0...gradient.stops.length)
      {
         var stop = gradient.stops[i];
         gfx.beginFill(stop.colour.getRGB());
         gfx.drawRect(x,36,stopW-8,24);
         if (i==currentId)
         {
            gfx.endFill();
            gfx.drawRect(x-2,36-2,stopW-4,28);
         }
         x+=stopW;
      }

      if (currentId>=0 && currentId<gradient.stops.length)
         positionMarker.x = Std.int(mWidth*gradient.stops[currentId].position - positionMarker.width*0.5);
   }

   public function setGradient(inGrad:Gradient)
   {
      updateLockout++;
      gradient = inGrad.clone();
      setCurrentStop(0);
      spread.setIndex( Lambda.indexOf(spreads,gradient.spreadMethod) );
      type.setIndex( Lambda.indexOf(types,gradient.type) );
      interp.setIndex( Lambda.indexOf(interps,gradient.interpolationMethod) );
      updateLockout--;
      onGradientChange();
   }
}


