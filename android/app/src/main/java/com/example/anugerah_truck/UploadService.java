package com.example.anugerah_truck;

import android.app.Service;
import android.app.job.JobParameters;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.annotation.Nullable;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.anugerah_truck.db.LocationHelper;

import java.util.HashMap;
import java.util.Map;

import static java.lang.Thread.sleep;

public class UploadService extends Service {
    private LocationHelper locationHelper;

    private Context context = this;
    private Handler handler = null;
    public static Runnable runnable = null;
    private int executionTime = 300000;

    private boolean isUploadSuccess = true;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        locationHelper = new LocationHelper(getApplicationContext());
        locationHelper.open();

        Log.i("Message", "start upload service");

        handler = new Handler();
        runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    if (isNetworkConnected()) {
                        Log.i("Message", "terhubung internet");

//            Cursor cursor = locationHelper.getAllDataByQuery();
                        Cursor cursor = locationHelper.getAllData();

                        startUploadJob(cursor);

                    } else {
                        Log.i("Message", "tidak terhubung");
                    }
                } catch (Exception e) {

                }

                handler.postDelayed(runnable, executionTime);
            }
        };

        handler.postDelayed(runnable, 300000);
    }

    private void startUploadJob(Cursor cursor){

        if (cursor != null) {
            if (cursor.moveToFirst()) {
                do {
                    try{
                        String id = cursor.getString(cursor.getColumnIndex("_id"));
                        String userId = cursor.getString(cursor.getColumnIndex("user_id"));
                        String latitude = cursor.getString(cursor.getColumnIndex("latitude"));
                        String longitude = cursor.getString(cursor.getColumnIndex("longitude"));
                        Log.i("upload id: ", id);

                        //upload to server by id
                        uploadToServer(userId, latitude, longitude, id);

                        if (!isUploadSuccess){
                            break;
                        }

                        sleep(5000);

                        Log.i("status", "lanjutkan");

                    } catch (Exception e){

                    }

                } while (cursor.moveToNext());
            }
        }
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
                Log.i("response", response);
                isUploadSuccess = !isUploadSuccess;

                //hapus jika sukses
                deleteDataById(databaseId);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("response", String.valueOf(error));

                isUploadSuccess = !isUploadSuccess;
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

    private void deleteDataById(String id) {
        Log.i("delete", "delete id" + id);
        locationHelper.delete(id);
    }

    private boolean isNetworkConnected() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        return connectivityManager.getActiveNetworkInfo() != null && connectivityManager.getActiveNetworkInfo().isConnected();
    }
}
