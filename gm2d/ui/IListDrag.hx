package gm2d.ui;

import nme.events.MouseEvent;

enum ListDragPos
{
   PosAbove;
   PosOver;
   PosBelow;
}

interface IListDrag
{
   function listShouldDrag(item:Int,ev:MouseEvent) : Bool;
   function listCanDrop(src:Int,dest:Int,position:ListDragPos,ev:MouseEvent) : Bool;
   function listDoDrop(src:Int,dest:Int,position:ListDragPos,ev:MouseEvent):Void;
}


