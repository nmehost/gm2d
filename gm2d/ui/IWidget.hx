package gm2d.ui;


interface IWidget
{
   public function activate(inDirection:Int) : Void;
   public function onCurrentChanged(inCurrent:Bool) : Void;
   public function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool;
   public function wantsFocus() : Bool;
}


