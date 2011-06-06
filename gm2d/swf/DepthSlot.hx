package gm2d.swf;

import gm2d.swf.Character;
import gm2d.swf.DisplayAttributes;
import gm2d.geom.ColorTransform;
import gm2d.geom.Matrix;



class DepthSlot
{
   //static var sInstanceID = 1;

   public var mID:Int;
   public var mAttribs : DisplayAttributesList;
   public var mCharacter : Character;

   // This is used when building
   var mCurrentAttrib : DisplayAttributes;


   public function new(inCharacter:Character,inCharacterID:Int,
           inAttribs:DisplayAttributes)
   {
      mID = inCharacterID;
      mAttribs = [];
      mAttribs.push(inAttribs);
      mCurrentAttrib = inAttribs;
      mCharacter = inCharacter;
   }

   public function Move(inFrame:Int,
                  inMatrix:Matrix, inColTx:ColorTransform,
                  inRatio:Null<Int>)
   {
      mCurrentAttrib = mCurrentAttrib.clone();
      mCurrentAttrib.mFrame = inFrame;
      if (inMatrix!=null) mCurrentAttrib.mMatrix = inMatrix;
      if (inColTx!=null) mCurrentAttrib.mColorTransform = inColTx;
      if (inRatio!=null) mCurrentAttrib.mRatio = inRatio;
      mAttribs.push(mCurrentAttrib);
   }



   public function FindClosestFrame(inHintFrame:Int,inFrame:Int)
   {
      var n = mAttribs.length;
      if (inHintFrame>=0)
         inHintFrame = 0;
      if (inHintFrame>0)
      {
         if ( mAttribs[inHintFrame-1].mFrame > inFrame)
            inHintFrame = 0;
      }

      for(i in inHintFrame...n)
      {
         if (mAttribs[i].mFrame > inFrame)
            return inHintFrame;
         inHintFrame = i;
      }
      
      return 0;
   }


}



