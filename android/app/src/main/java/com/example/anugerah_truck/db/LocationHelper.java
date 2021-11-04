package com.example.anugerah_truck.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import com.example.anugerah_truck.model.LocationModel;

public class LocationHelper {

    private static String DATABASE_TABLE = DatabaseHelper.TABLE_NAME;
    private Context context;
    private DatabaseHelper databaseHelper;

    private SQLiteDatabase database;

    public LocationHelper(Context context) {
        this.context = context;
    }

    public LocationHelper open() throws SQLException {
        databaseHelper = new DatabaseHelper(context);
        database = databaseHelper.getWritableDatabase();
        return this;
    }

    public void close() {
        databaseHelper.close();
    }

    public long insert(LocationModel locationModel) {
        ContentValues initialValue = new ContentValues();
        initialValue.put(DatabaseHelper.FIELD_USER_ID, locationModel.getUserId());
        initialValue.put(DatabaseHelper.FIELD_LATITUDE, locationModel.getLatitude());
        initialValue.put(DatabaseHelper.FIELD_LONGITUDE, locationModel.getLongitude());
        initialValue.put(DatabaseHelper.FIELD_TANGGAL, locationModel.getTanggal());
        return database.insert(DATABASE_TABLE, null, initialValue);
    }

    public Cursor getAllData() {
        Cursor cursor = database.query(DATABASE_TABLE, new String[]{DatabaseHelper.FIELD_ID, DatabaseHelper.FIELD_USER_ID, DatabaseHelper.FIELD_LATITUDE, DatabaseHelper.FIELD_LONGITUDE, DatabaseHelper.FIELD_TANGGAL}, null, null, null, null, null);
        if (cursor != null) {
            cursor.moveToFirst();
        }
        return cursor;
    }

    public Cursor getAllDataByQuery() {
        String selectQuery = "SELECT * FROM location";
        Cursor cursor = database.rawQuery(selectQuery, null);
        return cursor;

    }

    public Cursor getTrackRow(String limit) {
        String selectQuery = "SELECT * FROM location LIMIT " + limit;
        Cursor cursor = database.rawQuery(selectQuery, null);
        return cursor;
    }

    public String getLastIdByLimit(String limit) {
        String lastId = "";
        String selectQuery = "SELECT * FROM location LIMIT " + limit;
        Cursor cursor = database.rawQuery(selectQuery, null);
        cursor.moveToLast();
        if (cursor.getCount() > 0) {
            lastId = cursor.getString(0);
        }
        return lastId;
    }

    public void delete(String _id) {
        this.database.delete(DATABASE_TABLE, "_id=" + _id, null);
    }


    public String getLastId() {
        String lastId = "";
        String selectQuery = "SELECT * FROM location";
        Cursor cursor = database.rawQuery(selectQuery, null);
        cursor.moveToLast();
        if (cursor.getCount() > 0) {
            lastId = cursor.getString(1);
        }
        return lastId;
    }

    public String getLastDataLat() {
        String result = "";
        String selectQuery = "SELECT * FROM location";
        Cursor cursor = database.rawQuery(selectQuery, null);
        cursor.moveToLast();
        if (cursor.getCount() > 0) {
            result = cursor.getString(4);
        }
        return result;
    }
}
