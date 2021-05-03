package com.example.anugerah_truck;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.anugerah_truck.db.LocationHelper;
import com.example.anugerah_truck.model.LocationModel;

import java.util.HashMap;
import java.util.Map;

public class  TrackingService extends Service implements LocationListener {
    public String TAG = "TrackingService";

    public Context context = this;
    public Handler handler = null;
    public static Runnable runnable = null;

    boolean isGPSEnable = false;
    boolean isNetworkEnable = false;
    double latNetwork, lngNetwork, latGPS, lngGps;
    public Location location;
    public LocationManager locationManager;

    public static LocationHelper locationHelper;
    public static LocationModel locationModel;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onCreate() {
        locationHelper = new LocationHelper(getApplicationContext());
        locationHelper.open();

        startForeground(12345678, getNotification());
        handler = new Handler();
        runnable = new Runnable() {
            @Override
            public void run() {
                Log.i(TAG, "Service running");

                if (isNetworkConnected()) {
                    Log.i("Connecting", String.valueOf(isNetworkConnected()));
                } else {
                    Log.i("Connecting", "Not connected");
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    getLocation();
                }

                handler.postDelayed(runnable, 300000);
            }
        };

        handler.postDelayed(runnable, 300000);
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "service destroy");
    }

    private boolean isNetworkConnected() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        return connectivityManager.getActiveNetworkInfo() != null && connectivityManager.getActiveNetworkInfo().isConnected();
    }

    @Override
    public void onStart(Intent intent, int startId) {
        super.onStart(intent, startId);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @SuppressLint("MissingPermission")
    private void getLocation() {

        locationHelper = new LocationHelper(context);
        locationHelper.open();

        locationModel = new LocationModel();

        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            Log.d(TAG, "Gagal gps");
            return;
        }

        locationManager = (LocationManager) getApplicationContext().getSystemService(LOCATION_SERVICE);
        isGPSEnable = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        isNetworkEnable = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);

        if (!isGPSEnable && !isNetworkEnable) {
            Log.i(TAG, "Disable network and gps");

        } else {
            if (isNetworkEnable) {
                location = null;
                locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 1000, 0, this);

                if (locationManager != null) {
                    location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);

                    if (location != null) {
                        Log.i(TAG, location.getLatitude() + "");
                        Log.i(TAG, location.getLongitude() + "");

                        latNetwork = location.getLatitude();
                        lngNetwork = location.getLongitude();
                    }
                }
            }

            if (isGPSEnable) {
                location = null;
                locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 0, this);

                if (locationManager != null) {
                    location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);

                    if (location != null) {
                        Log.i(TAG, location.getLatitude() + "");
                        Log.i(TAG, location.getLongitude() + "");

                        latGPS = location.getLatitude();
                        lngGps = location.getLongitude();
                    }
                }
            }

            locationModel.setUserId("1");

            if (isNetworkConnected()) {
                //GUNAKAN JARINGAN
                locationModel.setLatitude(String.valueOf(latNetwork));
                locationModel.setLongitude(String.valueOf(lngNetwork));

                //cek database
                Cursor cursor = locationHelper.getTrackRow("20");
                if (cursor != null) {
                    if(cursor.moveToFirst()){
                        Log.i(TAG, "ada data di database, antrikan");
                        Log.i("latitude", String.valueOf(latNetwork));
                        Log.i("longitude", String.valueOf(lngNetwork));

                        locationHelper.insert(locationModel);
                    } else{
                        //EMPTY
                        Log.i(TAG, "tidak ada data di database sqlite, upload langsung ke server");
                        uploadToServer("1", String.valueOf(latNetwork), String.valueOf(lngNetwork), "0");
                    }
                }

            } else {
                //GUNAKAN SINYAL GPS simpan di db sqlite
                locationModel.setLatitude(String.valueOf(latGPS));
                locationModel.setLongitude(String.valueOf(lngGps));
                locationHelper.insert(locationModel);
                Log.i("SUCCESS", "Saving success");
            }
        }
    }

    @Override
    public void onLocationChanged(Location location) {

    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    private void uploadToServer(String userId, String latitude, String longitude, String databaseId) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        String url = sharedPref.getString("URL", "");
        //upload data ke server
        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());

        //get url
        StringRequest postRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                Log.i(TAG, response);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e(TAG, String.valueOf(error));
            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<String, String>();

                params.put("id", userId);
                params.put("lat", latitude);
                params.put("long", longitude);
                params.put("id_database", databaseId);
                return params;
            }
        };
        queue.add(postRequest);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private Notification getNotification() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        NotificationChannel channel = new NotificationChannel("channel_01", "My Channel", NotificationManager.IMPORTANCE_DEFAULT);

        NotificationManager notificationManager = getSystemService(NotificationManager.class);
        notificationManager.createNotificationChannel(channel);

        Notification.Builder builder = new Notification.Builder(getApplicationContext(), "channel_01").setAutoCancel(true);
        return builder.build();
//        }

    }


}
