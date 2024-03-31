package gm2d.ui;

interface IDialog
{
   public function closeFrame():Void;
   public function asDialog():Dialog;
   public function asScreen():DialogScreen;
}
