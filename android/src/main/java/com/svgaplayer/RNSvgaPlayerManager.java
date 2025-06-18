package com.svgaplayer;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.viewmanagers.SvgaPlayerViewManagerDelegate;
import com.facebook.react.viewmanagers.SvgaPlayerViewManagerInterface;
import com.opensource.svgaplayer.SVGAParser;
import com.opensource.svgaplayer.SVGAVideoEntity;
import com.svgaplayer.events.TopFinishedEvent;
import com.svgaplayer.events.TopFrameEvent;
import com.svgaplayer.events.TopPercentage;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@ReactModule(name = RNSvgaPlayerManager.REACT_CLASS)
public class RNSvgaPlayerManager extends SimpleViewManager<RCTSVGAImageView> implements SvgaPlayerViewManagerInterface<RCTSVGAImageView> {
    public static final String REACT_CLASS = "SvgaPlayerView";
    private final ViewManagerDelegate<RCTSVGAImageView> mDelegate;

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    public RNSvgaPlayerManager() {
        mDelegate = new SvgaPlayerViewManagerDelegate<>(this);
    }

    @Nullable
    @Override
    protected ViewManagerDelegate<RCTSVGAImageView> getDelegate() {
        return mDelegate;
    }

    @NonNull
    @Override
    public RCTSVGAImageView createViewInstance(@NonNull ThemedReactContext c) {
        return new RCTSVGAImageView(c, null, 0);
    }
    @ReactProp(name = "source")
    public void setSource(final RCTSVGAImageView view, String source) {
        Context context = view.getContext();
        assert source != null;
        if (source.startsWith("http") || source.startsWith("https")) {
            try {
                new SVGAParser(context).parse(new URL(source), new SVGAParser.ParseCompletion() {
                    @Override
                    public void onError() {

                    }

                    @Override
                    public void onComplete(SVGAVideoEntity videoItem) {
                        view.setVideoItem(videoItem);
                        view.startAnimation();
                    }

                });
            } catch (Exception e) {
            }
        } else {
            try {
                new SVGAParser(context).decodeFromAssets(source, new SVGAParser.ParseCompletion() {
                    @Override
                    public void onError() {

                    }

                    @Override
                    public void onComplete(SVGAVideoEntity videoItem) {
                        view.setVideoItem(videoItem);
                        view.startAnimation();
                    }
                });
            } catch (Exception e) {
            }
        }
    }

    @ReactProp(name = "loops", defaultInt = 0)
    public void setLoops(RCTSVGAImageView view, int loops) {
        view.setLoops(loops);
    }

    @ReactProp(name = "clearsAfterStop", defaultBoolean = true)
    public void setClearsAfterStop(RCTSVGAImageView view, boolean clearsAfterStop) {
        view.setClearsAfterStop(clearsAfterStop);
    }

    @Override
    public void load(RCTSVGAImageView view, String source) {
        this.setSource(view,source);
    }

    @ReactProp(name = "currentState")
    public void setCurrentState(RCTSVGAImageView view, String currentState) {
        view.currentState = currentState;
        switch (currentState) {
            case "start":
                view.startAnimation();
                break;
            case "pause":
                view.pauseAnimation();
                break;
            case "stop":
                view.stopAnimation();
                break;
            case "clear":
                view.stopAnimation(true);
                break;
            default:
                break;
        }
    }

    @ReactProp(name = "toFrame", defaultFloat = -1.0f)
    public void setToFrame(RCTSVGAImageView view, float toFrame) {
        if (toFrame < 0) {
            return;
        }
        view.stepToFrame((int) toFrame, view.currentState.equals("play"));
    }

    @ReactProp(name = "toPercentage", defaultFloat = -1.0f)
    public void setToPercentage(RCTSVGAImageView view, float toPercentage) {
        if (toPercentage < 0) {
            return;
        }
        view.stepToPercentage((double) toPercentage, view.currentState.equals("play"));
    }

    @Override
    public void receiveCommand(@NonNull RCTSVGAImageView root, String commandId, @Nullable ReadableArray args) {
        super.receiveCommand(root, commandId, args);
        if ("load".equals(commandId)) {
            Assertions.assertNotNull(args);
            assert args != null;
            load(root, args.getString(0));
        } else  if ("startAnimation".equals(commandId)) {
             startAnimation(root);
        } else  if ("pauseAnimation".equals(commandId)) {
           pauseAnimation(root);

        }else   if ("stopAnimation".equals(commandId)) {
            stopAnimation(root);
        }
    }

    @Override
    public void startAnimation(RCTSVGAImageView view) {
        view.startAnimation();
    }

    @Override
    public void pauseAnimation(RCTSVGAImageView view) {
        view.pauseAnimation();
    }

    @Override
    public void stopAnimation(RCTSVGAImageView view) {
        view.stopAnimation(true);
    }
//    @Override
//    public void stepToFrame(RCTSVGAImageView view, float toFrame, boolean andPlay) {
//        if (toFrame < 0) {
//            return;
//        }
//        view.stepToFrame((int) toFrame, view.currentState.equals("play"));
//
//    }
//    @Override
//    public void stepToPercentage(RCTSVGAImageView view, float toPercentage, boolean andPlay) {
//        if (toPercentage < 0) {
//            return;
//        }
//        view.stepToPercentage((double) toPercentage, view.currentState.equals("play"));
//
//    }
@Override
public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    Map<String, Object> export = super.getExportedCustomDirectEventTypeConstants();
    if (export == null) {
        export = MapBuilder.newHashMap();
    }
    // Default events but adding them here explicitly for clarity
    export.put(TopFrameEvent.EVENT_NAME, MapBuilder.of("registrationName", "onFrame"));
    export.put(TopPercentage.EVENT_NAME, MapBuilder.of("registrationName", "onPercentage"));
    export.put(TopFinishedEvent.EVENT_NAME, MapBuilder.of("registrationName", "onFinished"));
       return export;
}
//    @Nullable
//    @Override
//    public Map<String, Object> getExportedCustomBubblingEventTypeConstants() {
//        Map<String, Object> map = new HashMap<>();
//        Map<String, Object> frameBubblingMap = new HashMap<>();
//        frameBubblingMap.put("phasedRegistrationNames", new HashMap<String, String>() {{
//            put("bubbled", "onFrame");
////            put("captured", "onFrameCapture");
//        }});
//
//        map.put("onFrame", frameBubblingMap);
//        Map<String, Object> percentageBubblingMap = new HashMap<>();
//        percentageBubblingMap.put("phasedRegistrationNames", new HashMap<String, String>() {{
//            put("bubbled", "onPercentage");
////            put("captured", "onFrameCapture");
//        }});
//
//        map.put("onPercentage", percentageBubblingMap);
//        Map<String, Object> finishBubblingMap = new HashMap<>();
//        finishBubblingMap.put("phasedRegistrationNames", new HashMap<String, String>() {{
//            put("bubbled", "onFinished");
////            put("captured", "onFrameCapture");
//        }});
//        map.put("onFinished",finishBubblingMap);
//        return map;
//    }

}
