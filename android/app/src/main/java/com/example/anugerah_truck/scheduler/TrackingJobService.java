package com.example.anugerah_truck.scheduler;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.os.Build;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.annotation.RequiresApi;

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

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class TrackingJobService extends JobService {
    public static final String TAG = TrackingJobService.class.getSimpleName();

    private LocationHelper locationHelper;

    @Override
    public boolean onStartJob(JobParameters params) {
        locationHelper = new LocationHelper(getApplicationContext());
        locationHelper.open();

        if (isNetworkConnected()) {
            Log.i(TAG, "terhubung internet");

           Cursor cursor = locationHelper.getAllDataByQuery();
            // Cursor cursor = locationHelper.getTrackRow("20");

           String lastId = locationHelper.getLastId();
            // String lastId = locationHelper.getLastIdByLimit("20");
            Log.i("last id", lastId);

            startUploadJob(params, cursor, lastId);

        } else {
            Log.i(TAG, "tidak terhubung");
            jobFinished(params, true);
        }

        return true;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        Log.i(TAG, "job stopped");
        return true;
    }

    private void startUploadJob(final  JobParameters job, Cursor cursor, String lastId){

        if (cursor != null) {
            if (cursor.moveToFirst()) {
                do {
                    try{
                        String id = cursor.getString(cursor.getColumnIndex("_id"));
                        String userId = cursor.getString(cursor.getColumnIndex("user_id"));
                        String latitude = cursor.getString(cursor.getColumnIndex("latitude"));
                        String longitude = cursor.getString(cursor.getColumnIndex("longitude"));
                        String tanggal = cursor.getString(cursor.getColumnIndex("tanggal"));
                        Log.i("upload id: ", id);

                        //upload to server by id
                        uploadToServer(userId, latitude, longitude, id, tanggal);

                        sleep(300000);

                        Log.i("status", "lanjutkan");

                        if (lastId.equals(id)){
                            //job finished
                            Log.i(TAG, "job selesai");
                            jobFinished(job, false);
                        }

                    } catch (Exception e){

                    }

                } while (cursor.moveToNext());
            }
        }
    }

    private void uploadToServer(String userId, String latitude, String longitude, String databaseId, String tanggal) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        String url = sharedPref.getString("URL", "");
        //upload data ke server
        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());

        //get url
        StringRequest postRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                Log.i(TAG, response);

                //hapus jika sukses
                deleteDataById(databaseId);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e(TAG, String.valueOf(error));
//                jobFinished(pa);
            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<String, String>();

                params.put("id", userId);
                params.put("lat", latitude);
                params.put("long", longitude);
                params.put("id_database", databaseId);
                params.put("tanggal", tanggal);
                return params;
            }
        };
        queue.add(postRequest);
    }

    private void deleteDataById(String id) {
        Log.i(TAG, "delete id" + id);
        locationHelper.delete(id);
    }

    private boolean isNetworkConnected() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        return connectivityManager.getActiveNetworkInfo() != null && connectivityManager.getActiveNetworkInfo().isConnected();
    }

}
