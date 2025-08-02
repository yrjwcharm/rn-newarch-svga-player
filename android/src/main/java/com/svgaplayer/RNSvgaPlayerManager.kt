package com.svgaplayer

import android.util.Log
import android.widget.ImageView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.MapBuilder
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.RNSvgaPlayerManagerDelegate
import com.facebook.react.viewmanagers.RNSvgaPlayerManagerInterface
import com.opensource.svgaplayer.SVGACache
import com.opensource.svgaplayer.SVGAParser
import com.opensource.svgaplayer.SVGAVideoEntity
import com.opensource.svgaplayer.utils.SVGARange
import com.svgaplayer.events.TopErrorEvent
import com.svgaplayer.events.TopLoadedEvent
import java.io.File
import java.io.FileInputStream
import java.net.URL


@ReactModule(name = RNSvgaPlayerManager.REACT_CLASS)
class RNSvgaPlayerManager() : SimpleViewManager<RNSvgaPlayer>(), RNSvgaPlayerManagerInterface<RNSvgaPlayer> {

  companion object {
    const val REACT_CLASS = "RNSvgaPlayer"
  }
  private val mDelegate: ViewManagerDelegate<RNSvgaPlayer> = RNSvgaPlayerManagerDelegate(this)

  override fun getName(): String = REACT_CLASS

  override fun getDelegate(): ViewManagerDelegate<RNSvgaPlayer>? = mDelegate

  override fun createViewInstance(c: ThemedReactContext): RNSvgaPlayer {
    return RNSvgaPlayer(c, null, 0)
  }
  @ReactProp(name = "source")
  override fun setSource(view: RNSvgaPlayer, source: String?) {
    val context = view.context
    source?.let {
      val parseCompletion = object : SVGAParser.ParseCompletion {
        override fun onError() {
          view.setVideoItem(null)
          view.clear()

          val errorData = Arguments.createMap()
          errorData.putString("error", "Failed to load SVGA : $it")
          val surfaceId = UIManagerHelper.getSurfaceId(context)
          val errorEvent = TopErrorEvent(surfaceId, view.id, errorData)
          val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(context as ThemedReactContext, view.id)
          dispatcher?.dispatchEvent(errorEvent)
        }

        override fun onComplete(videoItem: SVGAVideoEntity) {
          view.setVideoItem(videoItem)

          // 触发 onLoaded 事件
          val loadedData = Arguments.createMap()
          val surfaceId = UIManagerHelper.getSurfaceId(context)
          val loadedEvent = TopLoadedEvent(surfaceId, view.id, loadedData)
          val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(context as ThemedReactContext, view.id)
           dispatcher?.dispatchEvent(loadedEvent)

          if(view.autoPlay){
            view.startAnimationSafely()
          }
        }
      }

      when {
        it.startsWith("http") || it.startsWith("https") -> {
          SVGAParser(context).decodeFromURL(URL(it), parseCompletion)
        }
        it.startsWith("file://") -> {
          // 移除 file:// 前缀，获取实际文件路径
          val filePath = it.removePrefix("file://")
          val file = File(filePath)

          if (file.exists() && file.isFile) {
            val inputStream = FileInputStream(file)
            val cacheKey = SVGACache.buildCacheKey(it)
            SVGAParser(context).decodeFromInputStream(inputStream, cacheKey, parseCompletion)
          } else {
            parseCompletion.onError()
          }
        }
        else -> {
          Log.d("RNSvgaPlayerManager", "Loading from assets: $it")
          SVGAParser(context).decodeFromAssets(it, parseCompletion)
        }
      }
    }
  }
  @ReactProp(name = "loops", defaultInt = 0)
  override fun setLoops(view: RNSvgaPlayer, loops: Int) {
    view.loops = loops
  }
  @ReactProp(name = "clearsAfterStop", defaultBoolean = true)
  override fun setClearsAfterStop(view: RNSvgaPlayer, clearsAfterStop: Boolean) {
    view.clearsAfterDetached = clearsAfterStop
    view.clearsAfterStop = clearsAfterStop
  }
  @ReactProp(name = "autoPlay", defaultBoolean = true)
  override fun setAutoPlay(view: RNSvgaPlayer, autoPlay: Boolean) {
    view.autoPlay = autoPlay
  }
  @ReactProp(name = "align")
  override fun setAlign(view: RNSvgaPlayer, align: String?) {
    val scaleType = when (align) {
      "bottom" -> ImageView.ScaleType.FIT_END
      "top" -> ImageView.ScaleType.FIT_START
      "center" -> ImageView.ScaleType.FIT_CENTER
      else -> ImageView.ScaleType.FIT_CENTER
    }

    view.scaleType = scaleType
  }


  override fun receiveCommand(root: RNSvgaPlayer, commandId: String, args: ReadableArray?) {
    super.receiveCommand(root, commandId, args)
    when (commandId) {
      "startAnimation" -> startAnimation(root)
      "stopAnimation" -> stopAnimation(root)
      "pauseAnimation" -> pauseAnimation(root)
      "stepToFrame" -> {
        val frame = args?.getInt(0) ?: 0
        val andPlay = args?.getBoolean(1) ?: false
        stepToFrame(root, frame, andPlay)
      }
      "stepToPercentage" -> {
        val percentage = args?.getInt(0) ?: 0
        val andPlay = args?.getBoolean(1) ?: false
        stepToPercentage(root, percentage, andPlay)
      }
      "startAnimationWithRange" -> {
        val location = args?.getInt(0) ?: 0
        val length = args?.getInt(1) ?: 0
        val reverse = args?.getBoolean(2) ?: false
        startAnimationWithRange(root, location, length, reverse)
      }
      else -> {
        Log.w(REACT_CLASS, "Unknown command: $commandId")
      }
    }
  }

  override fun startAnimation(view: RNSvgaPlayer) {
    view.startAnimationSafely()
  }

  override fun stopAnimation(view: RNSvgaPlayer) {
    view.stopAnimation(view.clearsAfterStop)
  }

//  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any>? {
//    val export = super.getExportedCustomDirectEventTypeConstants()?.toMutableMap()
//      ?: mutableMapOf<String, Any>()
//
//    export[TopErrorEvent.EVENT_NAME] = mapOf("registrationName" to "onError")
//    export[TopFinishedEvent.EVENT_NAME] = mapOf("registrationName" to "onFinished")
//    export[TopLoadedEvent.EVENT_NAME] = mapOf("registrationName" to "onLoaded")
//    export[TopFrameEvent.EVENT_NAME] = mapOf("registrationName" to "onFrameChanged")
//    export[TopPercentageEvent.EVENT_NAME] = mapOf("registrationName" to "onPercentageChanged")
//
//    return export
//  }
  override fun getExportedCustomBubblingEventTypeConstants(): MutableMap<String, Any>? {
  val map = MapBuilder.builder<String, Any>()
    .put("topError", MapBuilder.of("registrationName", "onError"))
    .put("topFinished", MapBuilder.of("registrationName", "onFinished"))
    .put("topLoaded", MapBuilder.of("registrationName", "onLoaded"))
    .put("topFrameChanged", MapBuilder.of("registrationName", "onFrameChanged"))
    .put("topPercentageChanged", MapBuilder.of("registrationName", "onPercentageChanged"))
    .build()
  return map
  }

  override fun pauseAnimation(view: RNSvgaPlayer?) {
    view?.pauseAnimation()
  }

  override fun stepToFrame(view: RNSvgaPlayer?, frame: Int, andPlay: Boolean) {
    view?.stepToFrame(frame, andPlay);
  }

  override fun stepToPercentage(view: RNSvgaPlayer?, percentage: Int, andPlay: Boolean) {
    view?.stepToFrame(percentage, andPlay);
  }

  override fun startAnimationWithRange(
    view: RNSvgaPlayer?,
    location: Int,
    length: Int,
    reverse: Boolean
  ) {
    var  range = SVGARange(location, length)
    view?.startAnimation(range,reverse)
  }
}
