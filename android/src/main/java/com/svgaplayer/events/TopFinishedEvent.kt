package com.svgaplayer.events

import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class TopFinishedEvent(
    surfaceId: Int,
    viewTag: Int,
    private val eventData: WritableMap
) : Event<TopFinishedEvent>(surfaceId, viewTag) {

    companion object {
        const val EVENT_NAME = "onFinished"
    }

    override fun getEventName(): String = EVENT_NAME

    override fun getEventData(): WritableMap? = eventData
}
