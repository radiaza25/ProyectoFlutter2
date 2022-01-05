//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<address_search_field/AddressSearchFieldPlugin.h>)
#import <address_search_field/AddressSearchFieldPlugin.h>
#else
@import address_search_field;
#endif

#if __has_include(<battery/FLTBatteryPlugin.h>)
#import <battery/FLTBatteryPlugin.h>
#else
@import battery;
#endif

#if __has_include(<cloud_firestore/FLTFirebaseFirestorePlugin.h>)
#import <cloud_firestore/FLTFirebaseFirestorePlugin.h>
#else
@import cloud_firestore;
#endif

#if __has_include(<firebase_analytics/FLTFirebaseAnalyticsPlugin.h>)
#import <firebase_analytics/FLTFirebaseAnalyticsPlugin.h>
#else
@import firebase_analytics;
#endif

#if __has_include(<firebase_auth/FLTFirebaseAuthPlugin.h>)
#import <firebase_auth/FLTFirebaseAuthPlugin.h>
#else
@import firebase_auth;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<firebase_messaging/FLTFirebaseMessagingPlugin.h>)
#import <firebase_messaging/FLTFirebaseMessagingPlugin.h>
#else
@import firebase_messaging;
#endif

#if __has_include(<flutter_sms/FlutterSmsPlugin.h>)
#import <flutter_sms/FlutterSmsPlugin.h>
#else
@import flutter_sms;
#endif

#if __has_include(<google_maps_flutter/FLTGoogleMapsPlugin.h>)
#import <google_maps_flutter/FLTGoogleMapsPlugin.h>
#else
@import google_maps_flutter;
#endif

#if __has_include(<location/LocationPlugin.h>)
#import <location/LocationPlugin.h>
#else
@import location;
#endif

#if __has_include(<shared_preferences/FLTSharedPreferencesPlugin.h>)
#import <shared_preferences/FLTSharedPreferencesPlugin.h>
#else
@import shared_preferences;
#endif

#if __has_include(<sms/SmsPlugin.h>)
#import <sms/SmsPlugin.h>
#else
@import sms;
#endif

#if __has_include(<url_launcher/FLTURLLauncherPlugin.h>)
#import <url_launcher/FLTURLLauncherPlugin.h>
#else
@import url_launcher;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AddressSearchFieldPlugin registerWithRegistrar:[registry registrarForPlugin:@"AddressSearchFieldPlugin"]];
  [FLTBatteryPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTBatteryPlugin"]];
  [FLTFirebaseFirestorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseFirestorePlugin"]];
  [FLTFirebaseAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAnalyticsPlugin"]];
  [FLTFirebaseAuthPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAuthPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTFirebaseMessagingPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseMessagingPlugin"]];
  [FlutterSmsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterSmsPlugin"]];
  [FLTGoogleMapsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMapsPlugin"]];
  [LocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [SmsPlugin registerWithRegistrar:[registry registrarForPlugin:@"SmsPlugin"]];
  [FLTURLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTURLLauncherPlugin"]];
}

@end
