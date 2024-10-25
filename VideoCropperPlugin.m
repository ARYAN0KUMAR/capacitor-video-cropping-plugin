//
//  VideoCropperPlugin.m
//  VideoCropperProcessor
//
//  Created by korslet technologies on 16/10/24.
//

#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(VideoCropperPlugin, "VideoCropper",
  CAP_PLUGIN_METHOD(getContacts, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
)

