package gm2d.skin;

import nme.display.DisplayObject;
import nme.display.BitmapData;

enum BitmapStyle
{
   BitmapBitmap(bmp:BitmapData);
   // Skin is passed explicitly rather than relying on the factory closure's own captured `this` -
   // attribSet (which is where these live, eg. "ChromeButton" => {bitmap:BitmapFactory(...)}) is
   // shared by reference across every copyWithScale() result (Skin.shallowCopy() never rebuilds
   // it), so a factory bound to `this` at attribSet-construction time - which only ever runs once,
   // for the very first Skin - would otherwise silently render against that first Skin's stale
   // uiScale/colours forever, no matter which Skin is actually current.
   BitmapFactory(factory:Skin->String->Int->BitmapData);
   BitmapAndDisable(bmp:BitmapData,bmpDisabled:BitmapData);

   // Resolved by Skin.renderBitmapStyle(style,logicalSize) - given a *logical* pixel size,
   // render fresh at the current scale. Used by anything that owns a single icon outright
   // (Button.resolveIcon, Image.fromStyle), as opposed to the id/state styles above (used by
   // Renderer.getBitmap, looked up by id - eg. chrome/checkbox icons).
   BitmapResource(name:String);                              // Resources/Assets - raster or SVG, auto-detected
   BitmapRender(draw:(skin:Skin,pixelSize:Int)->BitmapData);  // hand-drawn icon (eg. circle/rect tool icons)
}
