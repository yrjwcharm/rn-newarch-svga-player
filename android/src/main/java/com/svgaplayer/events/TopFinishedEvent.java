package com.svgaplayer.events;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;

public class TopFinishedEvent extends Event<TopFinishedEvent> {
    public static String  EVENT_NAME = "onFinished";
    private WritableMap eventData;
    public TopFinishedEvent(int surfaceId, int viewTag, WritableMap data) {
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
