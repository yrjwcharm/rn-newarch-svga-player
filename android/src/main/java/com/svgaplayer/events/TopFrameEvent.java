package com.svgaplayer.events;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;

public class TopFrameEvent extends Event<TopFrameEvent> {
    public static String  EVENT_NAME = "onFrame";
    private WritableMap eventData;
    public TopFrameEvent(int surfaceId, int viewTag, WritableMap data) {
        super(surfaceId, viewTag);
        eventData = data;
    }

    @Override
    public String getEventName() {
        return EVENT_NAME;
    }

    @Nullable
    @Override
    protected WritableMap getEventData() {
        return eventData;
    }
}
