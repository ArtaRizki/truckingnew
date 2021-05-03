package com.example.anugerah_truck;

import com.baseflow.googleapiavailability.GoogleApiAvailabilityPlugin;
import com.baseflow.location_permissions.LocationPermissionsPlugin;
import com.baseflow.permissionhandler.PermissionHandlerPlugin;
import com.ephilia.background_location.BackgroundLocationPlugin;
import com.example.appsettings.AppSettingsPlugin;
import com.lyokone.location.LocationPlugin;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

public class Application extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FlutterFirebaseCorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        BackgroundChannel.registerWith(registry.registrarFor("com.example.anugerah_truck.BackgroundChannel"));
        BackgroundLocationPlugin.registerWith(registry.registrarFor("com.ephilia.background_location.BackgroundLocationPlugin"));
//        SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
////        LocationPlugin.registerWith(registry.registrarFor("com.lyokone.location.LocationPlugin"));
//        GoogleApiAvailabilityPlugin.registerWith(registry.registrarFor("com.baseflow.googleapiavailability.GoogleApiAvailabilityPlugin"));
//        AppSettingsPlugin.registerWith(registry.registrarFor("com.example.appsettings.AppSettingsPlugin"));
//        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
//        PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"));
//        LocationPermissionsPlugin.registerWith(registry.registrarFor("com.baseflow.location_permissions.LocationPermissionsPlugin"));
    }
}
