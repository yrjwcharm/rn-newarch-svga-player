package com.svgaplayer

import android.content.Context
import android.util.Log
import com.facebook.infer.annotation.Assertions
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import android.widget.ImageView
import com.facebook.react.viewmanagers.RNSvgaPlayerManagerDelegate
import com.facebook.react.viewmanagers.RNSvgaPlayerManagerInterface
import com.opensource.svgaplayer.SVGAParser
import com.opensource.svgaplayer.SVGAVideoEntity
import com.opensource.svgaplayer.SVGACache
import com.svgaplayer.events.TopErrorEvent
import com.svgaplayer.events.TopFinishedEvent
import com.svgaplayer.events.TopLoadedEvent
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.net.URL

@ReactModule(name = RNSvgaPlayerManager.NAME)
class RNSvgaPlayerManager : SimpleViewManager<RNSvgaPlayer>(), RNSvgaPlayerManagerInterface<RNSvgaPlayer> {

  companion object {
    const val NAME = "RNSvgaPlayer"
  }

  private val mDelegate: ViewManagerDelegate<RNSvgaPlayer> = RNSvgaPlayerManagerDelegate(this)

  override fun getName(): String = NAME

  override fun getDelegate(): ViewManagerDelegate<RNSvgaPlayer>? = mDelegate

  override fun createViewInstance(c: ThemedReactContext): RNSvgaPlayer {
    return RNSvgaPlayer(c, null, 0)
  }

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

  override fun setLoops(view: RNSvgaPlayer, loops: Int) {
    view.loops = loops
  }

  override fun setClearsAfterStop(view: RNSvgaPlayer, clearsAfterStop: Boolean) {
    view.clearsAfterDetached = clearsAfterStop
    view.clearsAfterStop = clearsAfterStop
  }

  override fun setAutoPlay(view: RNSvgaPlayer, autoPlay: Boolean) {
    view.autoPlay = autoPlay
  }

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
    }
  }

  override fun startAnimation(view: RNSvgaPlayer) {
    view.startAnimationSafely()
  }

  override fun stopAnimation(view: RNSvgaPlayer) {
    view.stopAnimation(true)
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
    val export = super.getExportedCustomDirectEventTypeConstants()?.toMutableMap()
      ?: mutableMapOf<String, Any>()

    export[TopErrorEvent.EVENT_NAME] = mapOf("registrationName" to "onError")
    export[TopFinishedEvent.EVENT_NAME] = mapOf("registrationName" to "onFinished")
    export[TopLoadedEvent.EVENT_NAME] = mapOf("registrationName" to "onLoaded")

    return export
  }
}
