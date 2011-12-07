package gm2d.ui;

import gm2d.ui.Button;

class RadioGroup<Key>
{
   var buttons:Array<Button>;
   var keys:Array<Keys>;
   var onButton:Dynamic->Void;

   public function new(inOnButton:Key->Void)
   {
      onButton = inOnButton;
      button = new Array<Button>();
      keys = new Array<Key>();
   }
   public function setState(inKey:Key)
   {
      for(i=0...keys.length)
         buttons[i].down = keys[i]==inKey;
   }
   public function add(inButton:Button, inKey:Key) : Button
   {
      buttons.push(inButton);
      keys.push(inKey);
      inButton.onClick = function() { setState(inKey); onButton(inKey); }
      return inButton;
   }
}


