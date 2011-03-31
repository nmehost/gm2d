package gm2d.events;

#if flash
typedef ProgressEvent = flash.events.ProgressEvent;
#else
typedef ProgressEvent = nme.events.ProgressEvent;
#end
