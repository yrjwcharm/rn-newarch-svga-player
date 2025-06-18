package com.svgaplayer;

import android.content.Context;
import android.util.AttributeSet;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.UIManagerHelper;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.EventDispatcher;
import com.opensource.svgaplayer.SVGACallback;
import com.opensource.svgaplayer.SVGAImageView;
import com.svgaplayer.events.TopFinishedEvent;
import com.svgaplayer.events.TopFrameEvent;
import com.svgaplayer.events.TopPercentage;

public class RCTSVGAImageView extends SVGAImageView {
    protected String currentState;
    public RCTSVGAImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.setCallback(new SVGACallback() {

            @Override
            public void onStep(int frame, double percentage) {
                WritableMap payload = Arguments.createMap();
                payload.putInt("value",frame);
                WritableMap map = Arguments.createMap();
                map.putDouble("value", percentage);
                int surfaceId = UIManagerHelper.getSurfaceId(context);
                TopFrameEvent tce = new TopFrameEvent(surfaceId, getId(), payload);
                TopPercentage tc =new TopPercentage(surfaceId,getId(),map);
                dispatchEvent(tce);
                dispatchEvent(tc);
            }

            @Override
            public void onRepeat() {

            }

            @Override
            public void onPause() {

            }

            @Override
            public void onFinished() {
                WritableMap map = Arguments.createMap();
                map.putString("action","onFinished");
                ThemedReactContext context = (ThemedReactContext) getContext();
                EventDispatcher dispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, getId());
                int surfaceId = UIManagerHelper.getSurfaceId(RCTSVGAImageView.this);

                TopFinishedEvent tce = new TopFinishedEvent(surfaceId, getId(), map);

                if (dispatcher != null) {
                    dispatcher.dispatchEvent(tce);
                }
            }
        });
    }
    protected void dispatchEvent(Event event) {
        ThemedReactContext context = (ThemedReactContext) getContext();
        EventDispatcher dispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, getId());
        if (dispatcher != null) {
            dispatcher.dispatchEvent(event);
        }
    }
}
