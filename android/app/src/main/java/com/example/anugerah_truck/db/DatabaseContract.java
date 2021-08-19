package com.example.anugerah_truck.db;

import android.provider.BaseColumns;

public class DatabaseContract {
    static String TABLE_LOCATION = "location";

    static final class LocationColumn implements BaseColumns {
        static String user_id = "user_id";
        static String latitude = "latitude";
        static String longitude = "longitude";
        static String tanggal = "tanggal";
    }
}
