package gm2d.ui;

import sys.thread.Mutex;
import sys.thread.Thread;
import nme.display.*;
import gm2d.svg.*;

private class Job
{
   var filename:String;
   var widget:Widget;
   var size:Size;
   var bmp:BitmapData;

   public function new(inFilename:String, inWidget:Widget, inSize:Size)
   {
      filename = inFilename;
      widget = inWidget;
      size = inSize;
   }

   public function run()
   {
      try
      {
         var content = sys.io.File.getContent(filename);
         var xml = Xml.parse(content);
         var svg = new Svg(xml,true);
         var renderer = new SvgRenderer(svg);
         var scale = Math.min(size.x/svg.width, size.y/svg.height);
         bmp = renderer.renderBitmap(scale);
      }
      catch(e:Dynamic)
      {
      }
   }

   public function ok() return bmp!=null;

   public function apply()
   {
      if (bmp!=null)
      {
         //trace("apply " + bmp.width + "x" + bmp.height);
         widget.setBitmap(bmp);
      }
   }
}

class AsyncThumbnailer
{
   static var lock:Mutex;
   static var queue = new Array<Job>();
   static var procThread:Thread;

   static function add(job:Job)
   {
      if (lock==null)
      {
         lock = new Mutex();
         lock.acquire();
         procThread = Thread.create(threadLoop);
      }
      else
         lock.acquire();

      queue.push(job);
      if (queue.length==1)
         procThread.sendMessage(null);
      lock.release();
   }
   static function remove(job:Job)
   {
      lock.acquire();
      queue.remove(job);
      lock.release();
   }

   static function threadLoop()
   {
      while(true)
      {
         var job:Job = null;
         lock.acquire();
         if (queue.length>0)
            job = queue.shift();
         lock.release();
         if (job!=null)
         {
            job.run();
            if (job.ok())
               nme.app.Application.runOnMainThread( job.apply );
         }
         else
            Thread.readMessage(true);
      }
   }

   public static function factory(filename:String, widget:Widget, size:Size)
   {
      var job = new Job(filename,widget,size);
      add(job);
      widget.addEventListener( nme.events.Event.REMOVED_FROM_STAGE, (_)->remove(job) );
   }
}

