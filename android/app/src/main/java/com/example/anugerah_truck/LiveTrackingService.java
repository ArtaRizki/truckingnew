package com.example.anugerah_truck;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.location.Location;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.preference.PreferenceManager;
import android.util.Log;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.anugerah_truck.db.LocationHelper;
import com.example.anugerah_truck.model.LocationModel;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import static java.lang.Thread.sleep;

public class LiveTrackingService extends Service {
    private final LocationServiceBinder binder = new LocationServiceBinder();
    private final String TAG = "LiveTrackingService";

    private LocationListener mLocationListener;
    private LocationManager mLocationManager;
    private NotificationManager notificationManager;

    private final int LOCATION_INTERVAL = 1000;
    private final int LOCATION_DISTANCE = 0;

    public Context context = this;
    public Handler handler = null;
    public static Runnable runnable = null;
    boolean isGPSEnable = false;
    boolean isNetworkEnable = false;
    public Location location;
    public LocationManager locationManager;

    public static LocationHelper locationHelper;
    public static LocationModel locationModel;

    private LiveTrackingService gpsService;

    Messenger mMessenger;

    @Override
    public IBinder onBind(Intent intent) {
//        mMessenger = new Messenger(new IncomingHandler(this));
        return (IBinder) binder;
//        return mMessenger.getBinder();
    }

    static class IncomingHandler extends Handler {
        private Context applicationContext;

        IncomingHandler(Context context) {
            applicationContext = context.getApplicationContext();
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 1:
                    Log.d("Masuk service", "masuk pesan");
                    Intent intent = new Intent(applicationContext, LiveTrackingService.class);
                    applicationContext.startService(intent);

                    final Intent intent2 = new Intent(applicationContext, UploadService.class);
                    applicationContext.startService(intent2);
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    private class LocationListener implements android.location.LocationListener {
        private Location lastLocation = null;
        private final String TAG = "LocationListener";
        private Location mLastLocation;

        public LocationListener(String provider) {
            mLastLocation = new Location(provider);
        }

        @Override
        public void onLocationChanged(Location location) {
//            mLastLocation = location;
//            Log.d(TAG, "LocationChanged: "+location);
        }

        @Override
        public void onProviderDisabled(String provider) {
            Log.e(TAG, "onProviderDisabled: " + provider);
        }

        @Override
        public void onProviderEnabled(String provider) {
            Log.e(TAG, "onProviderEnabled: " + provider);
        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
            Log.e(TAG, "onStatusChanged: " + status);
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        return START_NOT_STICKY;
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    @Override
    public void onCreate() {
        Log.d(TAG, "onCreate");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForeground(12345678, getNotification());
        } else {
            startTracking();
            startTimer();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mLocationManager != null) {
            try {
                mLocationManager.removeUpdates(mLocationListener);
            } catch (Exception ex) {
                Log.i(TAG, "fail to remove location listners, ignore", ex);
            }
        }
    }

    private void initializeLocationManager() {
        locationHelper = new LocationHelper(getApplicationContext());
        locationHelper.open();

        if (mLocationManager == null) {
            mLocationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        }

        locationManager = (LocationManager) getApplicationContext().getSystemService(LOCATION_SERVICE);

        isNetworkEnable = mLocationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        isGPSEnable = mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);

    }

    private Timer mTimer1;
    private TimerTask mTt1;
    private Handler mTimerHandler = new Handler();

    private void startTimer() {
        mTimer1 = new Timer();
        mTt1 = new TimerTask() {
            public void run() {
                mTimerHandler.post(new Runnable() {
                    @TargetApi(Build.VERSION_CODES.M)
                    public void run() {
                        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                            Log.d(TAG, "Gagal gps");
                            // TODO: Consider calling
                            //    Activity#requestPermissions
                            // here to request the missing permissions, and then overriding
                            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                            //                                          int[] grantResults)
                            // to handle the case where the user grants the permission. See the documentation
                            // for Activity#requestPermissions for more details.
                            return;
                        }

                        final Location tes = mLocationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
                        String tanggal = sdf.format(new Date());

                        mLocationManager.requestSingleUpdate(LocationManager.NETWORK_PROVIDER, mLocationListener, null);
                        Log.d(TAG, "Location : " + String.valueOf(mLocationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)));

                        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
                        int defaultValue = 0;
                        String defaultValue2 = "";
                        SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
                        final String highScore = (String) prefs.getString("flutter.UserID", "0");
                        Log.d(TAG, "shared dpreferences : " + String.valueOf(highScore));
                        String url = sharedPref.getString("URL", defaultValue2);

                        //Cek jaringan
                        if (isNetworkConnected()) {
                            //CEK DATABASE
                            if (isNotEmpty()) {

                                Log.i(TAG, "Koneksi terhubung");

                                syncDatabase(url, highScore, String.valueOf(tes.getLatitude()), String.valueOf(tes.getLongitude()), tanggal);
                            } else {
                                //langsung upload ke server
                                String databaseId = "0";
                                uploadToServer(url, databaseId, highScore, String.valueOf(tes.getLatitude()), String.valueOf(tes.getLongitude()), false, tanggal);
                            }
                        } else {

                            Log.e(TAG, "Koneksi tidak terhubung");

                            if (!isNetworkEnable && !isGPSEnable){
                                //NO connection
                            }

                            if (isGPSEnable) {
                                location = null;
                                mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 0, mLocationListener);

                                if (mLocationManager != null) {
                                    location = mLocationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);

                                    if (location != null) {
                                        Log.i(TAG, location.getLatitude() + "");
                                        Log.i(TAG, location.getLongitude() + "");
                                        saveToDatabase(highScore, String.valueOf(location.getLatitude()), String.valueOf(location.getLongitude()), tanggal);
                                    }
                                }
                            }

                        }
                    }
                });
            }
        };

        mTimer1.schedule(mTt1, 300000, 300000);
    }

    public void startTracking() {
        initializeLocationManager();
        mLocationListener = new LocationListener(LocationManager.GPS_PROVIDER);
        Log.d(TAG, "Start Service");

        try {
            mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, LOCATION_DISTANCE, mLocationListener);
//                mLocationManager.requestSingleUpdate(LocationManager.GPS_PROVIDER, mLocationListener, null);

        } catch (java.lang.SecurityException ex) {
            Log.d(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            Log.d(TAG, "gps provider does not exist " + ex.getMessage());
        }

    }

    public void stopTracking() {
        this.onDestroy();
    }

    @TargetApi(Build.VERSION_CODES.O)
    private Notification getNotification() {

        startTracking();
        startTimer();

//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        NotificationChannel channel = new NotificationChannel("channel_01", "My Channel", NotificationManager.IMPORTANCE_DEFAULT);

        NotificationManager notificationManager = getSystemService(NotificationManager.class);
        notificationManager.createNotificationChannel(channel);

        Notification.Builder builder = new Notification.Builder(getApplicationContext(), "channel_01")
                .setContentTitle("Anugerah Trucking")
                .setContentText("Anugerah Trucking Is Running")
                .setAutoCancel(true);
        return builder.build();
//        }
    }


    public class LocationServiceBinder extends Binder {
        public LiveTrackingService getService() {
            return LiveTrackingService.this;
        }
    }

    private boolean isNetworkConnected() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        return connectivityManager.getActiveNetworkInfo() != null && connectivityManager.getActiveNetworkInfo().isConnected();
    }

    private void uploadToServer(String url, String databaseId, String userId, String latitude, String longitude, boolean isUploadFromDb, String tanggal) {

        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());

        StringRequest postRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        // response
                        Log.i("Response", response);

                        try{
                            JSONObject object = new JSONObject(response);
                            String status = object.optString("status");

                            if (status.equals("TRUE")){
                                Log.e("status api", status);
                                //jika sukses hapus
                                if (isUploadFromDb) {
                                    Log.i("tes", "data dihapus");
                                    deleteDataById(databaseId);
                                }
                            }
                        } catch (Exception e){
                            Log.e(TAG, e.getMessage());
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // error
                        Log.i("Error.Response", String.valueOf(error));

                        //simpan ke database jika upload bukan dari database
                        if (!isUploadFromDb){
                            Log.i(TAG, "simpan pertama kali");
                            saveToDatabase(userId, latitude, longitude, tanggal);
                        }
                    }
                }
        ) {
            @Override
            protected Map<String, String> getParams() {
                Map<String, String> params = new HashMap<String, String>();
                params.put("id", String.valueOf(userId));
                params.put("long", longitude);
                params.put("lat", latitude);
                params.put("tanggal", tanggal);

                return params;
            }
        };
        queue.add(postRequest);
    }

    //CEK DATA DI DATABASE
    private boolean isNotEmpty() {
        Cursor cursor = locationHelper.getTrackRow("20");

        if (cursor != null) {
            if (cursor.moveToFirst()) {
                //ADA DATA
                return true;
            }
        }
        return false;
    }

    //Sync database
    private void syncDatabase(String url, String userId, String latitude, String longitude, String tanggal) {
        Cursor cursor = locationHelper.getAllData();

        saveToDatabase(userId, latitude, longitude, tanggal);

        try {

            // If moveToFirst() returns false then cursor is empty
            if (!cursor.moveToFirst()) {
                return;
            }

            do {
                String databaseId = cursor.getString(cursor.getColumnIndex("_id"));
                String uploadUserId = cursor.getString(cursor.getColumnIndex("user_id"));
                String uploadLat = cursor.getString(cursor.getColumnIndex("latitude"));
                String uploadLong = cursor.getString(cursor.getColumnIndex("longitude"));
                String uploadTanggal = cursor.getString(cursor.getColumnIndex("tanggal"));
                Log.i("upload id: ", databaseId);
                uploadToServer(url, databaseId, uploadUserId, uploadLat, uploadLong, true, uploadTanggal);

            } while (cursor.moveToNext());


        } finally {
            // Don't forget to close the Cursor once you are done to avoid memory leaks.
            // Using a try/finally like in this example is usually the best way to handle this
            cursor.close();

            // close the database
        }
//            if (cursor.moveToFirst()) {
//                try {
//                    String databaseId = cursor.getString(cursor.getColumnIndex("_id"));
//                    String uploadUserId = cursor.getString(cursor.getColumnIndex("user_id"));
//                    String uploadLat = cursor.getString(cursor.getColumnIndex("latitude"));
//                    String uploadLong = cursor.getString(cursor.getColumnIndex("longitude"));
//                    String uploadTanggal = cursor.getString(cursor.getColumnIndex("tanggal"));
//                    Log.i("upload id: ", databaseId);
//
//					//Synchronous
//
//                    uploadToServer(url, databaseId, uploadUserId, uploadLat, uploadLong, true, uploadTanggal);
////                        sleep(5000);
//
//                } catch (Exception e) {
//                    Log.e(TAG, e.getMessage());
//                }
//            }
//        }
    }

    //SAVE ke Database
    private void saveToDatabase(String userId, String latitude, String longitude, String tanggal) {
        locationModel = new LocationModel();

        locationModel.setUserId(userId);
        locationModel.setLatitude(latitude);
        locationModel.setLongitude(longitude);
        locationModel.setTanggal(tanggal);

        locationHelper.insert(locationModel);

        Log.i("Status", "lokasi di simpan");
    }

    private void deleteDataById(String id) {
        Log.i("delete", "delete id" + id);
        locationHelper.delete(id);
    }

    private ServiceConnection serviceConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            String name = className.getClassName();
            io.flutter.Log.d("Tes", "12345");
            if (name.endsWith("LiveTrackingService")) {
                io.flutter.Log.d("Tes", "12345");
                gpsService = ((LiveTrackingService.LocationServiceBinder) service).getService();
            }
        }

        public void onServiceDisconnected(ComponentName className) {
            if (className.getClassName().equals("LiveTrackingService")) {
                gpsService = null;
            }
        }
    };

}
