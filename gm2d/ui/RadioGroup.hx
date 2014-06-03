package gm2d.ui;

import gm2d.ui.Button;

class RadioGroup<Key>
{
   public var onButton:Dynamic->Void;
   public var onItem:Int->Void;

   var buttons:Array<Button>;
   var keys:Array<Key>;

   public function new(inOnButton:Key->Void)
   {
      onButton = inOnButton;
      buttons = new Array<Button>();
      keys = new Array<Key>();
   }
   public function setState(inKey:Key)
   {
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
      keys.push(inKey);
      var nextIndex = keys.length;
      inButton.mCallback = onItem!=null ?
          function() { setIndex(nextIndex%keys.length); } :
          function() { setState(inKey); onButton(inKey); }
      return inButton;
   }
}


