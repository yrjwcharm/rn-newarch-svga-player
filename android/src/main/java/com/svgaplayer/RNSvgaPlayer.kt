package com.svgaplayer

import android.content.Context
import android.util.AttributeSet
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event
import com.facebook.react.uimanager.events.EventDispatcher
import com.opensource.svgaplayer.SVGACallback
import com.opensource.svgaplayer.SVGAImageView
import com.svgaplayer.events.TopFinishedEvent

class RNSvgaPlayer(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : SVGAImageView(context, attrs, defStyleAttr) {

  var currentState: String? = null
  var autoPlay: Boolean = true
  private var isStarting: Boolean = false  // 标记是否正在开始动画

  init {
    this.callback = object : SVGACallback {
      override fun onStep(frame: Int, percentage: Double) {
         // 动画开始播放，清除启动标记
         isStarting = false
      }

      override fun onRepeat() {
        // Empty implementation
      }

      override fun onPause() {
        // Empty implementation
      }

      override fun onFinished() {
        // 如果是因为startAnimation内部调用stop而触发的，忽略这次回调
        if (isStarting) {
          return
        }

        val map = Arguments.createMap()
        map.putBoolean("finished", true)
        val context = getContext() as ThemedReactContext
        val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, id)
        val surfaceId = UIManagerHelper.getSurfaceId(this@RNSvgaPlayer)
        val tce = TopFinishedEvent(surfaceId, id, map)

        dispatcher?.dispatchEvent(tce)
      }
    }
  }

  // 自定义启动方法，设置标记
  fun startAnimationSafely() {
    isStarting = true
    startAnimation()
  }

  protected fun dispatchEvent(event: Event<*>) {
    val context = getContext() as ThemedReactContext
    val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, id)
    dispatcher?.dispatchEvent(event)
  }
}
