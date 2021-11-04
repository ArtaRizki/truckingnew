package com.example.anugerah_truck.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DatabaseHelper extends SQLiteOpenHelper {
    public static String DATABASE_NAME = "dblocation";
    public static String TABLE_NAME = "location";
    public static String FIELD_USER_ID = "user_id";
    public static String FIELD_LATITUDE = "latitude";
    public static String FIELD_LONGITUDE = "longitude";
    public static String FIELD_TANGGAL = "tanggal";
    public static String FIELD_ID = "_id";

    private static final int DATABASE_VERSION = 2;

    public static String CREATE_TABLE_LOCATION = "create table " + TABLE_NAME + " ("
            + FIELD_ID + " integer primary key autoincrement, "
            + FIELD_USER_ID + " text not null, "
            + FIELD_LATITUDE + " text not null,"
            + FIELD_TANGGAL + " text not null,"
            + FIELD_LONGITUDE + " text not null );";

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase sqLiteDatabase) {
        sqLiteDatabase.execSQL(CREATE_TABLE_LOCATION);
    }

    @Override
    public void onUpgrade(SQLiteDatabase sqLiteDatabase, int oldVersion, int newVersion) {
        sqLiteDatabase.execSQL("DROP TABLE IF EXISTS " + TABLE_NAME);
        onCreate(sqLiteDatabase);
    }
}
