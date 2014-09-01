package gm2d;

import gm2d.ui.Phase;

class Doable
{
   public function new(inDo:Void->Void, inUndo:Void->Void)
   {
      doFunc = inDo;
      undoFunc = inUndo;
   }

   public var doFunc:Void->Void;
   public var undoFunc:Void->Void;
}


class Edit
{
   public function new(inName:String)
   {
      name = inName;
      jobs = new Array<Doable>();
   }
   public function continueDo(inDo:Void->Void, inUndo:Void->Void)
   {
      if (jobs.length>0)
      {
         jobs[jobs.length-1].doFunc = inDo;
      }
      else
         add(inDo,inUndo);
   }
   public function add(inDo:Void->Void, inUndo:Void->Void)
   {
      jobs.push(new Doable(inDo,inUndo));
   }
   public function undo()
   {
      var len = jobs.length;
      for(j in 0...len)
         jobs[len-1-j].undoFunc();
   }
   public function redo()
   {
      for(doable in jobs)
         doable.doFunc();
   }

   public var name:String;
   public var jobs:Array<Doable>;
}




class Ado
{
   public var edits:Array<Edit>;
   public var undone:Array<Edit>;
   public var edit:Edit;
   var held = false;

   public function new()
   {
      edits = [];
      undone = [];
   }

   public function hold()
   {
      held = true;
   }

   public function clear()
   {
      held = false;
      edits = [];
      undone = [];
      edit = null;
   }

   public function continueEdit(inName:String)
   {
      if (held)
         return;
      if (edit!=null && edit.name!=inName)
         finishEdit();
      if (edit==null)
         edit = new Edit(inName);
   }

   public function beginEdit(inName:String)
   {
      if (held)
         return;
      finishEdit();
      edit = new Edit(inName);
   }

   public function finishEdit()
   {
      if (held)
         return;
      if (edit!=null && edit.jobs.length>0)
      {
         undone=null;
         edits.push(edit);
      }
      edit = null;
   }

   public function editPhase(inName:String,
                  inDo:Void->Void,
                  inUndo:Void->Void,
                  inPhase:Int)
   {
      if ( (inPhase & Phase.BEGIN)>0 )
      {
         setDo(inName,inDo,inUndo);
      }
      else
      {
         continueEdit(inName);
         edit.continueDo(inDo,inUndo);
         inDo();
      }

      if ( (inPhase&Phase.END)>0 )
         finishEdit();
   }


   public function addDo( inDo:Void->Void, inUndo:Void->Void)
   {
      add(inDo,inUndo);
      inDo();
   }

   public function add( inDo:Void->Void, inUndo:Void->Void)
   {
      if (held)
         return;
      if (edit==null)
         throw "add without begin";
      edit.add(inDo,inUndo);
   }

   public function setDo( inName:String, inDo:Void->Void, inUndo:Void->Void)
   {
      if (held)
      {
         inDo();
         return;
      }
      finishEdit();
      undone = null;
      edit = new Edit(inName);
      edit.add(inDo,inUndo);
      inDo();
   }


   public function undo() : Bool
   {
      if (held)
         return false;
      finishEdit();
      if (edits.length>0)
      {
         var e = edits.pop();
         e.undo();
         if (undone==null)
            undone = new Array<Edit>();
         undone.push(e);
         return true;
      }
      return false;
   }

   public function redo() : Bool
   {
      if (held)
         return false;
      finishEdit();
      if (undone!=null && undone.length>0)
      {
         var e = undone.pop();
         e.redo();
         edits.push(e);
         return true;
      }
      return false;
   }

}
