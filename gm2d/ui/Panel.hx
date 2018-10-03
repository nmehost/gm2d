package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.Shape;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;
import gm2d.ui.Layout;
import gm2d.ui.TextLabel;
import gm2d.skin.Renderer;
import gm2d.skin.Skin;

typedef Hash<T> = haxe.ds.StringMap<T>;

class Panel extends Widget
{
   var mGridLayout:GridLayout;
   var mItemGrid:GridLayout;
   var mButtonLayout:Layout;
   var mLayoutDirty:Bool;
   var mLabelLookup:Hash<TextLabel>;
   var mButtons:Array<Widget>;
   var mTitle:String;
   var mPane:Pane;

   public function new(inTitle:String = "",?inIcon:Image, ?inLineage:Array<String>, ?inAttribs:{})
   {
      if (inTitle!="")
         inAttribs = Widget.addAttribs(inAttribs, {title:inTitle});
      super(Widget.addLine(inLineage,"Panel"),inAttribs);

      mButtons = [];
      mLayoutDirty = true;
      mTitle = inTitle;

      mGridLayout = new GridLayout(1,"vertical");
      mGridLayout.setSpacing(0, mRenderer.getDefaultFloat("buttonGap",0) );
      mGridLayout.stretch();
      mItemGrid = new GridLayout(2,"items");
      mItemGrid.setColStretch(1,1);
      mItemGrid.setAlignment(Layout.AlignTop);
      mItemGrid.setSpacing(mRenderer.getDefaultFloat("labelGap", Skin.scale(10)),
                           mRenderer.getDefaultFloat("lineGap",Skin.scale(10)) );
      mButtonLayout = new GridLayout(null,"buttons");
      mButtonLayout.setSpacing(  mRenderer.getDefaultFloat("buttonSpacing",0) ,0);
      //mButtonLayout.setBorders(0,10,0,10);

      if (inIcon!=null)
      {
         var hLayout = new HorizontalLayout([0,1]);
         addChild(inIcon);
         hLayout.add(inIcon.getLayout());
         hLayout.add(mItemGrid.stretch());
         hLayout.setSpacing(mRenderer.getDefaultFloat("labelGap", Skin.scale(10)),
                           mRenderer.getDefaultFloat("lineGap",Skin.scale(10)) );
         mGridLayout.add(hLayout.stretch());
      }
      else
      {
         mGridLayout.add(mItemGrid.stretch());
      }
      mGridLayout.setRowStretch(0,1);
      mGridLayout.setRowStretch(1,0);
      setItemLayout( mGridLayout );
      //build();
   }

   public function getVerticalLayout() return mGridLayout;

   public function setButtonLayout(layout:Layout) mButtonLayout = layout;

   public function setItemSize(inSize:Int)
   {
       mItemGrid.setMinColWidth(1,inSize);
   }

   public function showDialog(inCentre=true,inAutoClose=true,?inAttribs:{}, ?inLineage:Array<String>)
   {
      var dlg = new gm2d.ui.Dialog(getPane(),inAttribs, inLineage);
      dlg.show(inCentre,inAutoClose);
      return dlg;
   }


   public function setStretchX(inItemStretch:Int=33)
   {
      mGridLayout.mAlign =  Layout.AlignTop;
      mGridLayout.setColStretch(0,1);
      mItemGrid.mAlign =  Layout.AlignTop;
      mItemGrid.setColStretch(0,inItemStretch);
      mItemGrid.setColStretch(1,100);
      return this;
   }

   override public function getPane()
   {
      if (mPane==null)
      {
         applyStyles();
         var w = getLayout().getBestWidth();
         var h = getLayout().getBestHeight(w);
         mPane = new Pane(this, mTitle, 0);
         mPane.setMinSize(w,h);
         mPane.itemLayout = getLayout();
         mPane.setFlags( mPane.getFlags() | Dock.RESIZABLE );
      }
      return mPane;
   }

   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float)
   {
      mGridLayout.setBorders(inL,inT,inR,inB);
   }

   public function addUI(inItem:gm2d.ui.Widget)
   {
      mLayoutDirty = true;
       if (inItem==null)
      {
         mItemGrid.add(null);
         return;
      }
      addChild(inItem);
      mItemGrid.add( inItem.getLayout().stretch() );
   }
   public function addButton(inButton:gm2d.ui.Widget)
   {
      if (mButtons.length==0)
      {
         mGridLayout.setSpacing(0, mRenderer.getDefaultFloat("buttonGap",0) );
         mGridLayout.add(mButtonLayout);
      }

      mLayoutDirty = true;
      addChild(inButton);
      mButtons.push(inButton);
      mButtonLayout.add( inButton.getLayout() );
   }

   public function addTextButton(inText:String, ?inOnClick:Void->Void)
   {
      var button = Button.TextButton(inText,inOnClick==null ? gm2d.Game.closeDialog : inOnClick);
      addButton(button);
      return this;
   }



   public function addObj(inObj:nme.display.DisplayObject,?inAlign:Null<Int>)
   {
      mLayoutDirty = true;
      addChild(inObj);
      if (Std.is(inObj,Widget))
      {
         var layout = cast(inObj,Widget).getLayout();
         mItemGrid.add( layout );
      }
      else
      {
         var layout = new DisplayLayout(inObj);
         if (inAlign!=null)
            layout.mAlign = inAlign;
         else
            layout.mAlign = Layout.AlignStretch;
         mItemGrid.add( layout );
      }
   }

   public function addLabelObj(inLabel:String,inObj:DisplayObject,?inName:String,?inAlign:Null<Int>)
   {
      addLabel(inLabel,inName,inAlign);
      addObj(inObj,inAlign);
   }

   
   public function addLabelUI(inLabel:String,inObj:Widget,?inAlign:Null<Int>)
   {
      addLabel(inLabel,null,inAlign);
      addUI(inObj);
   }
 
   public function addLabel(inText:String,?inName:String,?inAlign:Null<Int>)
   {
      mLayoutDirty = true;
      if (inText==null)
      {
         mItemGrid.add(null);
         return;
      }
      var label = new TextLabel(inText, ["Panel:" + mTitle, "PanelText"]);
      addChild(label);
      mItemGrid.add( label.getLayout() );

      if (inName!=null)
      {
          if (mLabelLookup!=null)
             mLabelLookup = new Hash<TextLabel>();
          mLabelLookup.set(inName,label);
      }
   }
   public function setLabel(inName:String,inValue:String)
   {
      mLabelLookup.get(inName).text = inValue;
   }



}
