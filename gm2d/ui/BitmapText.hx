package gm2d.ui;

import gm2d.text.TextField;
import gm2d.text.TextFieldType;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.blit.Viewport;
import gm2d.blit.Layer;
import gm2d.blit.Tile;


class BitmapText extends Base
{
   var mViewport:Viewport;
   var mLayer:Layer;
   var mCaretLayer:Layer;
   var mOnChange:String->Void;
   var mFont:BitmapFont;
   var mText:String;
   var mInput:Bool;
   var mInsertPos:Int;
   var mSelStart:Int;
   var mSelEnd:Int;
   var mSelectionAnchored:Bool;
   var mSelectionAnchor:Int;
   var mCaretCode:Int;
   var mCaretTile:Tile;

   // TextField-like API
   public var text(getText,setText):String;
   public var type(getType,setType) : TextFieldType;
   public var selectable:Bool;


   public function new(inFont:BitmapFont, inVal="", ?onUpdate:String->Void)
   {
      super();
      mViewport = Viewport.create(50,50, true, 0xffffff, false );
      mLayer = mViewport.createLayer();
      mFont = inFont;
      mOnChange = onUpdate;
      mInput = false;
      mInsertPos = 0;
      mSelStart = mSelEnd = 0;
      selectable = true;

      addChild(mViewport);

      setCaret("|".charCodeAt(0));

      setText(inVal);

      var occ = onCurrentChanged;
      var me = this;
      onCurrentChanged = function(inCurrent:Bool)
      {
         occ(inCurrent);
         me.setCaretState(inCurrent);
      };
   }

   public function setCaret(inCharCode:Int)
   {
      mCaretTile = mFont.getGlyph(inCharCode);
      if (mCaretLayer!=null)
         renderCaret();
   }


   public override function wantFocus() { return mInput; }

   function ClearSelection()
   {
      mSelStart = mSelEnd = -1;
      mSelectionAnchored = false;
      //Rebuild();
   }

   function DeleteSelection()
   {
      if (mSelEnd > mSelStart && mSelStart>=0)
      {
         mInsertPos = mSelStart;
         mSelStart = mSelEnd = -1;
         mSelectionAnchored = false;
         mText = mText.substr(0,mSelStart) + mText.substr(mSelEnd);
         RebuildText();
      }
   }

   function OnMoveKeyStart(inShift:Bool)
   {
      if (inShift && selectable)
      {
         if (!mSelectionAnchored)
         {
            mSelectionAnchored = true;
            mSelectionAnchor = mInsertPos;
            //Game.setSelectionOwner(this);
         }
      }
      else
         ClearSelection();
   }

   function OnMoveKeyEnd()
   {
      if (mSelectionAnchored)
      {
         if (mInsertPos<mSelectionAnchor)
         {
            mSelStart = mInsertPos;
            mSelEnd =mSelectionAnchor;
         }
         else
         {
            mSelStart = mSelectionAnchor;
            mSelEnd =mInsertPos;
         }
      }
   }


   public override function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool
   {
      if (!mInput) return false;
      var code = event.keyCode;
      if (code == Keyboard.DOWN || code==Keyboard.TAB || code==Keyboard.UP)
         return false;

      var key = event.keyCode;
      //trace(key);
      var ascii = event.charCode;
      var shift = event.shiftKey;

      // ctrl-c
      if ( ascii==3 )
      {
         if (mSelEnd > mSelStart && mSelStart>=0)
         {
            //Manager.setClipboardString( text.substr(mSelStart,mSelEnd-mSelStart) );
         }
         return true;
      }

         if (key==Keyboard.LEFT)
         {
            OnMoveKeyStart(shift);
            mInsertPos--;
            OnMoveKeyEnd();
         }
         else if (key==Keyboard.RIGHT)
         {
            OnMoveKeyStart(shift);
            mInsertPos++;
            OnMoveKeyEnd();
         }
         else if (key==Keyboard.HOME)
         {
            OnMoveKeyStart(shift);
            mInsertPos = 0;
            OnMoveKeyEnd();
         }
         else if (key==Keyboard.END)
         {
            OnMoveKeyStart(shift);
            mInsertPos = mText.length;
            OnMoveKeyEnd();
         }
         /*
          Cut + Paste
         else if ( (key==Keyboard.INSERT && shift) || ascii==22)
         {
            DeleteSelection();
            var str = Manager.getClipboardString();
            if (str!=null && str!="")
            {
               mText = mText.substr(0,mInsertPos) + str + mText.substr(mInsertPos);
               mInsertPos += str.length;
            }
         }
         else if ( ascii==24 || (key==Keyboard.DELETE && shift) )
         {
            if (mSelEnd > mSelStart && mSelStart>=0)
            {
               Manager.setClipboardString( mText.substr(mSelStart,mSelEnd-mSelStart) );
               if (ascii!=3)
                  DeleteSelection();
            }
         }
         */

         else if (key==Keyboard.DELETE || key==Keyboard.BACKSPACE)
         {
            if (mSelEnd> mSelStart && mSelStart>=0)
               DeleteSelection();
            else
            {
               if (key==Keyboard.BACKSPACE && mInsertPos>0)
                  mInsertPos--;
               var l = mText.length;
               if (mInsertPos>l)
               {
                  if (l>0)
                     mText = mText.substr(0,l-1);
               }
               else
               {
                   mText = mText.substr(0,mInsertPos) + mText.substr(mInsertPos+1);
               }
            }
         }
         else if (ascii>=32 && ascii<128)
         {
            if (mSelEnd> mSelStart && mSelStart>=0)
               DeleteSelection();
            mText = mText.substr(0,mInsertPos) + String.fromCharCode(ascii) + mText.substr(mInsertPos);
            mInsertPos++;
         }

         if (mInsertPos<0)
            mInsertPos = 0;
         var l = mText.length;
         if (mInsertPos>l)
            mInsertPos = l;

         RebuildText();

      return true;
   }

   function renderCaret()
   {
      mCaretLayer.clear();
      mCaretLayer.addTile(mCaretTile,0,0);
   }

   public function setCaretState(inCurrent:Bool)
   {
      if (mInput)
      {
          if (mCaretLayer==null)
          {
             mCaretLayer = mViewport.createLayer();
             renderCaret();
             RebuildText();
          }
          mCaretLayer.visible = inCurrent;
      }
   }


   public function getText() { return mText; }
   public function setText(inText:String)
   {
      mText = inText;
      ClearSelection();
      mInsertPos = mText.length;
      RebuildText();
      return mText;
   }


   function RebuildText()
   {
      mLayer.clear();
      var x = 0.0;
      for(i in 0...mText.length)
      {
         var code = mText.charCodeAt(i);
         var tile = mFont.getGlyph(code);
         if (tile!=null)
            mLayer.addTile(tile,x,0);
         if (i==mInsertPos && mCaretLayer!=null && mCaretLayer.visible)
            mCaretLayer.offsetX = x;
         x += mFont.getAdvance(code);
      }
      if (mText.length==mInsertPos && mCaretLayer!=null && mCaretLayer.visible)
         mCaretLayer.offsetX = x;
   }

   public function getType() { return mInput ? TextFieldType.INPUT : TextFieldType.DYNAMIC;}
   public function setType(inType:TextFieldType)
   {
      mInput = inType==TextFieldType.INPUT;
      return inType;
   }

   public override function layout(inW:Float, inH:Float)
   {
       mViewport.resize(Std.int(inW),Std.int(inH));
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xffffff);
       gfx.drawRect(0.5,0.5,inW-1,inH);
       gfx.lineStyle();
   }

}


