package com.svgaplayer.events;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;

public class TopPercentage extends Event<TopPercentage> {
    public static String  EVENT_NAME = "onPercentage";
    private WritableMap eventData;
    public TopPercentage(int surfaceId, int viewTag, WritableMap data) {
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
