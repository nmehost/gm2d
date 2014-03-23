package gm2d.ui2;


interface IWidget
{
   public function activate(inDirection:Int) : Void;
   public function onCurrentChanged(inCurrent:Bool) : Void;
   public function onKeyDown(event:nme.events.KeyboardEvent ) : Bool;
   public function wantsFocus() : Bool;
}


