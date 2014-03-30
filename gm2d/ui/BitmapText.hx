package gm2d.ui;

import nme.text.TextField;
import nme.text.TextFieldType;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.blit.Viewport;
import gm2d.blit.Layer;
import gm2d.blit.Tile;
import nme.ui.Keyboard;
import haxe.Timer;


class BitmapText extends Control
{
   static var mCopyBuffer:String = "";

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
   var mSelectionOverlay:Shape;
   var mCharPos:Array<Float>;
   var mScrollPos:Float;
   var mCurrent:Bool;
   var mTimer:Timer;

   // TextField-like API
   public var text(get_text,set_text):String;
   public var type(get_type,set_type) : TextFieldType;
   public var selectable:Bool;


   public function new(inFont:BitmapFont, inVal="", ?onUpdate:String->Void)
   {
      super();
      mViewport = Viewport.create(50,50, Viewport.BG_TRANSPARENT, 0xffffff, false );
      mLayer = mViewport.createLayer();
      mFont = inFont;
      mOnChange = onUpdate;
      wantFocus = mInput = false;
      mInsertPos = 0;
      mSelStart = mSelEnd = 0;
      selectable = true;
      mScrollPos = 0;

      addChild(mViewport);

      setCaret("|".charCodeAt(0));

      set_text(inVal);
      mCharPos = [];
      mCurrent = false;
      #if !flash
      needsSoftKeyboard = true;
      #end
   }

   override function onCurrentChanged(inCurrent:Bool)
   {
      super.onCurrentChanged(inCurrent);
      mCurrent = inCurrent;
      setCaretState(inCurrent);
      if (inCurrent && mInput)
      {
         if (mTimer==null)
         {
            mTimer = new Timer(500);
            mTimer.run = onTimer;
         }
         //requestSoftKeyboard();
      }
      else
      {
         if (mTimer!=null)
            mTimer.stop();
         mTimer = null;
      }
   }

   function onTimer()
   {
      if (mCurrent && mInput)
      {
         if (mCaretLayer!=null)
            mCaretLayer.visible = !mCaretLayer.visible;
      }
      else if (mTimer!=null)
      {
         mTimer.stop();
         mTimer = null;
      }
   }

   public function setCaret(inCharCode:Int)
   {
      mCaretTile = mFont.getGlyph(inCharCode);
      if (mCaretLayer!=null)
         renderCaret();
   }


   function ClearSelection()
   {
      mSelStart = mSelEnd = -1;
      mSelectionAnchored = false;
      if (mSelectionOverlay!=null)
         mSelectionOverlay.visible = false;
      //Rebuild();
   }

   function DeleteSelection()
   {
      if (mSelEnd > mSelStart && mSelStart>=0)
      {
         mText = mText.substr(0,mSelStart) + mText.substr(mSelEnd);
         mInsertPos = mSelStart;
         mSelStart = mSelEnd = -1;
         mSelectionAnchored = false;
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
      if (mInsertPos<0) mInsertPos = 0;
      if (mInsertPos>mText.length) mInsertPos = mText.length;

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


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      if (!mInput) return false;
      var code = event.keyCode;
      if (code == Keyboard.DOWN || code==Keyboard.TAB || code==Keyboard.UP)
         return false;

      if (code==Keyboard.ENTER)
      {
         //stage.showKeyboard(false);
         // Set current to "next" ?
         clearCurrent();
      }

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
         // Cut + Paste
         else if ( (key==Keyboard.INSERT && shift) || ascii==22)
         {
            DeleteSelection();
            // TODO: make system-wide
            var str = mCopyBuffer;
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
               // TODO: make system-wide
               mCopyBuffer = mText.substr(mSelStart,mSelEnd-mSelStart);
               if (ascii!=3)
                  DeleteSelection();
            }
         }

         else if (key==Keyboard.DELETE || key==Keyboard.BACKSPACE)
         {
            if (mSelEnd> mSelStart && mSelStart>=0)
            {
               DeleteSelection();
            }
            else
            {
               /* diff between delete and backspace on mac
                  if (key==Keyboard.DELETE || mInsertPos>0) */
               {
                  if (key==Keyboard.BACKSPACE && mInsertPos>0 )
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
      if (mCaretTile!=null)
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


   public function get_text() { return mText; }
   public function set_text(inText:String)
   {
      mText = inText;
      ClearSelection();
      mInsertPos = mText.length;
      RebuildText(true);
      return mText;
   }


   function RebuildText(inScrollToEnd:Bool = false)
   {
      mLayer.clear();
      var x = 0.0;
      mCharPos = [];
      for(i in 0...mText.length)
      {
         mCharPos.push(x);
         var code = mText.charCodeAt(i);
         var tile = mFont.getGlyph(code);
         if (tile!=null)
            mLayer.addTile(tile,x,0);
         x += mFont.getAdvance(code);
      }
      mCharPos.push(x);
      var w = mViewport.viewWidth;
      var edge = w/8;

      if (x<=w)
         mScrollPos = 0;
      else if (mScrollPos>x-w)
         mScrollPos = x-w;
      else if (inScrollToEnd)
      {
         mScrollPos = x-w;
         if (mInput)
           mScrollPos += edge;
      }

      
      var selected =  selectable && (mSelStart<mSelEnd);

      if ( selected || mInput )
      {
         if (x<w)
            mScrollPos = 0;
         else
         {
            var show = selected ? (mSelStart==mSelectionAnchor ? mSelEnd : mSelStart) : mInsertPos;
            var show_x = mCharPos[show];
         

            var current = show_x - mScrollPos;
            if (current<edge)
            {
               mScrollPos = show_x - edge;
               if (mScrollPos<0) mScrollPos = 0;
            }
            else if (current>w - edge)
            {
               mScrollPos =  show_x - w + edge;
               if (mScrollPos>x-w+edge) mScrollPos = x-w+edge;
            }
         }
      }

      mLayer.offsetX = -mScrollPos;


      if (mCaretLayer!=null && mCurrent && mInsertPos>=0)
         mCaretLayer.offsetX = mCharPos[mInsertPos] - mScrollPos;

      var want_selection = false;
      if (selected)
      {
         var x0 = mCharPos[mSelStart] - mScrollPos;
         if (x0<0) x0 = 0;
         var x1 = mCharPos[mSelEnd] - mScrollPos;
         if (x1>mViewport.viewWidth) x1 = mViewport.viewWidth;

         if (x1>x0)
         {
            if (mSelectionOverlay==null)
            {
               mSelectionOverlay = new Shape();
               addChild(mSelectionOverlay);
               mSelectionOverlay.blendMode = nme.display.BlendMode.INVERT;
            }
            var gfx = mSelectionOverlay.graphics;
            gfx.clear();
            gfx.beginFill(0xffffff);
            gfx.drawRect(x0,0,x1-x0,mViewport.viewHeight);
            mSelectionOverlay.visible = true;
            want_selection = true;
         }
      }

      if (!want_selection && mSelectionOverlay!=null && mSelectionOverlay.visible)
         mSelectionOverlay.visible = false;
   }

   public function get_type() { return mInput ? TextFieldType.INPUT : TextFieldType.DYNAMIC;}
   public function set_type(inType:TextFieldType)
   {
      wantFocus = mInput = inType==TextFieldType.INPUT;
      RebuildText(true);
      return inType;
   }

   public function layout(inW:Float, inH:Float)
   {
       mViewport.resize(Std.int(inW),Std.int(inH));
       RebuildText();
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xffffff);
       gfx.drawRect(0.5,0.5,inW-1,inH);
       gfx.lineStyle();
   }

}


