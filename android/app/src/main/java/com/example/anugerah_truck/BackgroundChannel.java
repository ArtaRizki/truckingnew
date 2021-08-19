package com.example.anugerah_truck;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.preference.PreferenceManager;

import androidx.annotation.NonNull;

//import com.ephilia.background_location.BackgroundLocationPlugin;
//import com.ephilia.background_location.LiveTrackingService;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class BackgroundChannel extends MainActivity implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private MethodChannel channel;
    public LiveTrackingService gpsService;
    public boolean mTracking = false;
    private Context mContext;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.d("Tes 123", "Atached");
        this.mContext = binding.getApplicationContext();
        channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), "com.example.dev/tracking_offline");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d("Tes 123", "Detached");
        this.mContext = binding.getApplicationContext();
        channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), "com.example.dev/tracking_offline");
        channel.setMethodCallHandler(this);
    }


    public static void registerWith(PluginRegistry.Registrar registrar) {
        Log.d("Tes 123", "Registerd");
        final MethodChannel[] channel = {new MethodChannel(registrar.messenger(), "com.example.dev/tracking_offline")};
        final Activity activity = registrar.activity();
        final LiveTrackingService[] gpsService = new LiveTrackingService[1];
        channel[0].setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            Context mContext = registrar.activeContext();
            private ServiceConnection serviceConnection = new ServiceConnection() {
                public void onServiceConnected(ComponentName className, IBinder service) {
                    String name = className.getClassName();
                    io.flutter.Log.d("Tes", "12345");
                    if (name.endsWith("LiveTrackingService")) {
                        io.flutter.Log.d("Tes", "12345");
                gpsService[0] = ((com.example.anugerah_truck.LiveTrackingService.LocationServiceBinder) service).getService();
                    }
                }

                public void onServiceDisconnected(ComponentName className) {
                    if (className.getClassName().equals("LiveTrackingService")) {
                        gpsService[0] = null;
                    }
                }
            };

            public void upload(String status) {
                RequestQueue queue = Volley.newRequestQueue(mContext);
                SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(mContext);
                SharedPreferences prefs = mContext.getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
                String url = sharedPref.getString("URL", "");
                final String userID = (String) prefs.getString("flutter.UserID", "0");
                url = url.replace("/liveTrack", "/sendStatus");
                url = url + "?User=" + userID + "&Status=" + status;
                Log.d("URL", url);

                // Request a string response from the provided URL.
                StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                        new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {
                                // Display the first 500 characters of the response string.
                                Log.d("Response", response);
                            }
                        }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Log.d("Response Error", "Error");
                    }
                });

                // Add the request to the RequestQueue.
                queue.add(stringRequest);
            }

            @Override
            public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("getPlatformVersion1")) {
                    try {
                        if (gpsService[0] != null && gpsService.length > 0) {
                            Log.d("Tes 123", "tes");
                            io.flutter.Log.d("Tes 123", "Seharusnya stop disiini");
                            final Intent intent = new Intent(mContext, com.example.anugerah_truck.LiveTrackingService.class);
                            mContext.stopService(intent);
                            //                        mContext.unbindService(serviceConnection);

                            final Intent intent2 = new Intent(mContext, UploadService.class);
                            mContext.stopService(intent2);
                            mContext.unbindService(serviceConnection);
                            upload("1");
//                        .startServices();
                            result.success("Android " + android.os.Build.VERSION.RELEASE);
                        } else {
//                            upload("0");
                        }
                    } catch (Exception e) {
                        upload("2");
                    }
                } else if (call.method.equals("getPlatformVersion4")) {
                    // try {
                        upload("1");
                        Log.d("Tes 123", "Aaaa");
                        String userID = call.argument("URL");
                        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(mContext);;

                        SharedPreferences.Editor editor = sharedPref.edit();
                        editor.putString("URL", userID);
                        editor.commit();

                        final Intent intent = new Intent(mContext, com.example.anugerah_truck.LiveTrackingService.class);
                        mContext.startService(intent);
                        mContext.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);

                        final Intent intent2 = new Intent(mContext, UploadService.class);
                        mContext.startService(intent2);
                        mContext.bindService(intent2, serviceConnection, Context.BIND_AUTO_CREATE);
                        result.success("Android " + "Aaaa");
                    // } catch (Exception e) {
                    //     upload("2");
                    // }
                } else {
                    result.notImplemented();
                }
            }
        });
//        channel.setMethodCallHandler(new BackgroundChannel());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion1")) {
            Log.d("Tes 123", "tes");
            io.flutter.Log.d("Tes 123", "Seharusnya stop disiini");
            final Intent intent = new Intent(mContext, com.example.anugerah_truck.LiveTrackingService.class);
            mContext.stopService(intent);
            mContext.unbindService(serviceConnection);

            final Intent intent2 = new Intent(mContext, UploadService.class);
            mContext.stopService(intent2);
            mContext.unbindService(serviceConnection);
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("getPlatformVersion4")) {
//            mContext = getApplicationContext();
            Log.d("Tes 123", "Aaaa");
            String userID = "tes";
            SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(mContext);;

            SharedPreferences.Editor editor = sharedPref.edit();
            editor.putString("URL", userID);
            editor.commit();

            final Intent intent = new Intent(mContext, com.example.anugerah_truck.LiveTrackingService.class);
            mContext.startService(intent);
            mContext.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);

            final Intent intent2 = new Intent(mContext, UploadService.class);
            mContext.startService(intent2);
            mContext.bindService(intent2, serviceConnection, Context.BIND_AUTO_CREATE);
            result.success("Android " + "Aaaa");
//            String userID = call.argument("URL");
//            Log.d("Tes 123", userID);
//            SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(mContext);;
//
//            SharedPreferences.Editor editor = sharedPref.edit();
//            editor.putString("URL", userID);
//            editor.commit();
//
//            final Intent intent = new Intent(mContext, LiveTrackingService.class);
//            mContext.startService(intent);
//            mContext.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
////                            gpsService.startTracking();
////                            gpsService.startTracking();
////                            new Intent(getActivity(), gpsService.startTracking());
////                            final Intent intent2 = new Intent(getActivity(), NativeActivity.class);
////                            startActivity(intent2);
//            Log.d("Tes 123", userID);
//            String greetings = "Tes";
//            result.success(greetings);
        } else {
            result.notImplemented();
        }
    }

    private ServiceConnection serviceConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            String name = className.getClassName();
            io.flutter.Log.d("Tes", "12345");
            if (name.endsWith("LiveTrackingService")) {
                io.flutter.Log.d("Tes", "12345");
//                gpsService = ((com.example.anugerah_truck.LiveTrackingService.LocationServiceBinder) service).getService();
            }
        }

        public void onServiceDisconnected(ComponentName className) {
            if (className.getClassName().equals("LiveTrackingService")) {
                gpsService = null;
            }
        }
    };


}
