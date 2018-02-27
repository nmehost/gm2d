package gm2d.ui;

import gm2d.ui.Button;

class RadioGroup<Key>
{
   public var onButton:Dynamic->Void;
   public var onItem:Int->Void;
   public var buttons:Array<Button>;
   public var keys:Array<Key>;
   public var current:Null<Key>;

   public function new(inOnButton:Key->Void)
   {
      onButton = inOnButton;
      buttons = new Array<Button>();
      keys = new Array<Key>();
      current = null;
   }
   public function setState(inKey:Key)
   {
      current = inKey;
      for(i in 0...keys.length)
      {
         buttons[i].down = keys[i]==inKey;
         if (onItem!=null && keys[i]==inKey)
             onItem(i);
      }
   }
   public function setIndex(inIndex:Int)
   {
      setState(keys[inIndex]);
   }

   public function add(inButton:Button, inKey:Key) : Button
   {
      buttons.push(inButton);
      inButton.isToggle = true;
      keys.push(inKey);
      var nextIndex = keys.length;
      inButton.mCallback = onItem!=null ?
          function() { setIndex(nextIndex%keys.length); } :
          function() { setState(inKey); onButton(inKey); }
      return inButton;
   }
}


