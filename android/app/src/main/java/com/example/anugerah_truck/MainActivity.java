package com.example.anugerah_truck;

import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.preference.PreferenceManager;

import androidx.annotation.RequiresApi;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.anugerah_truck.scheduler.TrackingJobService;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.dev/tracking_offline";
    private Context context;
    private int jobId = 10;
    private static final String TAG = MainActivity.class.getSimpleName();

    private LiveTrackingService gpsService;

    public void upload(String status) {
        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SharedPreferences prefs = getApplicationContext().getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
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
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        this.context = getApplicationContext();
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getTracking")) {
                                try {
                                    String userID = call.argument("URL");
                                    //                                String userID = "aaa";
                                    Log.d("Tes 123", userID);
                                    SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
//                                    ;

                                    SharedPreferences.Editor editor = sharedPref.edit();
                                    editor.putString("URL", userID);
                                    editor.commit();

                                    final Intent intent = new Intent(context, LiveTrackingService.class);
                                    context.startService(intent);
                                    context.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);

                                    final Intent intent2 = new Intent(context, UploadService.class);
                                    context.startService(intent2);
                                    context.bindService(intent2, serviceConnection, Context.BIND_AUTO_CREATE);

//                                    startServices(this.context);
                                    Log.d("Tes 123", userID);
                                    String greetings = "Tes";
                                    result.success(greetings);
                                    upload("1");
                                } catch(Exception e) {
                                    upload("2");
                                }
                            } else if (call.method.equals("stopTrack")) {
                                // try {
                                if (gpsService != null) {
                                    final Intent intent = new Intent(context, LiveTrackingService.class);
                                    context.stopService(intent);
                                    //                                    context.unbindService(serviceConnection);

                                    final Intent intent2 = new Intent(context, UploadService.class);
                                    context.stopService(intent2);
                                    context.unbindService(serviceConnection);
                                    upload("1");

                                    Log.d("Tes 123", "Seharusnya stop disiini");
                                }
                                // } catch(Exception e) {
                                //     Log.d("Error", e);
                                //     upload("2");
                                // }
                            }
                            // TODO
                        }
                );
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private int getTracking() {


        Thread thread2 = new Thread(new Runnable() {
            @Override
            public void run() {
                final Intent intent = new Intent(context, TrackingService.class);
                context.startService(intent);
//                startJob();
            }
        });
        thread2.start();

        Thread thread1 = new Thread(new Runnable() {
            @Override
            public void run() {
                final Intent intent2 = new Intent(context, UploadService.class);
                context.startService(intent2);
//                startJob();
            }
        });
        thread1.start();

        return 1;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void startJob() {
        if (isJobRunning(context)) {
            Log.i(TAG, "Job service telah di jadwalkan");
            return;
        }

        ComponentName serviceComponent = new ComponentName(this, TrackingJobService.class);
        JobInfo.Builder builder = new JobInfo.Builder(jobId, serviceComponent);
        builder.setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY);
        builder.setRequiresDeviceIdle(false);
        builder.setRequiresCharging(false);

        builder.setPeriodic(900000); //15 menit
        JobScheduler jobScheduler = (JobScheduler) getSystemService(Context.JOB_SCHEDULER_SERVICE);
        jobScheduler.schedule(builder.build());

        Log.i(TAG, "Job service di mulai");
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void cancelJob() {
        JobScheduler tm = (JobScheduler) getSystemService(context.JOB_SCHEDULER_SERVICE);
        tm.cancel(jobId);
        Log.i(TAG, "Job service di batalkan");
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private boolean isJobRunning(Context context) {
        boolean isScheduled = false;
        JobScheduler scheduler = (JobScheduler) context.getSystemService(Context.JOB_SCHEDULER_SERVICE);

        if (scheduler != null) {
            for (JobInfo jobInfo : scheduler.getAllPendingJobs()) {
                if (jobInfo.getId() == jobId) {
                    isScheduled = true;
                    break;
                }
            }
        }
        return isScheduled;
    }

    private ServiceConnection serviceConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            String name = className.getClassName();
            Log.d("Tes", "12345");
            if (name.endsWith("LiveTrackingService")) {
                Log.d("Tes", "12345");
                gpsService = ((LiveTrackingService.LocationServiceBinder) service).getService();
            }
        }

        public void onServiceDisconnected(ComponentName className) {
            if (className.getClassName().equals("LiveTrackingService")) {
                gpsService = null;
            }
        }
    };

    public void startServices(Context context){
        //start your service
        final Intent intent = new Intent(context, LiveTrackingService.class);
                                    context.startService(intent);
                                    context.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);

                                    final Intent intent2 = new Intent(context, UploadService.class);
                                    context.startService(intent2);
                                    context.bindService(intent2, serviceConnection, Context.BIND_AUTO_CREATE);
    }
    public void stopServices(Context context){
        //stop service
                                            final Intent intent = new Intent(context, LiveTrackingService.class);
                                    context.stopService(intent);
//                                    context.unbindService(serviceConnection);

                                    final Intent intent2 = new Intent(context, UploadService.class);
                                    context.stopService(intent2);
                                    context.unbindService(serviceConnection);
    }
//    public ServiceConnection getService(){
//        return gpsService;
//    }
}
