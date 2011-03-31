package gm2d.events;

#if flash
typedef SecurityErrorEvent = flash.events.SecurityErrorEvent;
#else
typedef SecurityErrorEvent = nme.events.SecurityErrorEvent;
#end
