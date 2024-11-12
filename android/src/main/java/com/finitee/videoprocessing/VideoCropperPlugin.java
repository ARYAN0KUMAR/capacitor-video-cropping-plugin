package com.finitee.videoprocessing;
import android.net.Uri;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;


import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.Session;
import com.arthenica.ffmpegkit.ReturnCode;

import java.io.File;
import java.util.UUID;

import android.database.Cursor;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.content.Context;
import android.content.ContentResolver;

import androidx.annotation.NonNull;


@CapacitorPlugin(name = "VideoCropper")
public class VideoCropperPlugin extends Plugin {

    private VideoCropper implementation = new VideoCropper();

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }

    //i have put this in FilePicker plugin
    public String getAbsolutePath(@NonNull Uri uri) {
        String[] projection = { MediaStore.MediaColumns.DATA };
        Cursor cursor = bridge.getContext().getContentResolver().query(uri, projection, null, null, null);

        if (cursor != null) {
            try {
                if (cursor.moveToFirst()) {
                    int columnIdx = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA);
                    return cursor.getString(columnIdx);
                }
            } finally {
                cursor.close();
            }
        }

        // Fallback for Android 10+ scoped storage where _DATA may be null
        if (DocumentsContract.isDocumentUri(bridge.getContext(), uri)) {
            String docId = DocumentsContract.getDocumentId(uri);
            String[] split = docId.split(":");
            String type = split[0];
            String relativePath = split[1];

            if ("primary".equalsIgnoreCase(type)) {
                return "file:///storage/emulated/0/" + relativePath;
            }
        }

        return null; // Absolute path not found
    }



    @PluginMethod
    public void cropVideo(PluginCall call) {
        String fileUrl = call.getString("fileUrl");
        Float cropX = call.getFloat("cropX");
        Float cropY = call.getFloat("cropY");
        Float cropWidth = call.getFloat("cropWidth");
        Float cropHeight = call.getFloat("cropHeight");

        if (fileUrl == null || cropX == null || cropY == null || cropWidth == null || cropHeight == null) {
            call.reject("Invalid arguments were passed");
            return;
        }


        //fileUrl = "file:///storage/emulated/0/DCIM/Camera/"+fileUrl;

        Uri contentUri = Uri.parse(fileUrl);


        // Generate a random file name
        String newFileName = "cropped_" + UUID.randomUUID().toString() + ".mp4";
        File outputFile = new File(getContext().getCacheDir(), newFileName);
        String outputFilePath = outputFile.getAbsolutePath();

        //String ffmpegCommand = String.format("-i \"%s\" -vf crop=%d:%d:%d:%d -c:v libx264 \"%s\"",
        //        contentUri, cropWidth, cropHeight, cropX, cropY, outputFilePath);

        String ffmpegCommand = String.format("-i \"%s\" -vf crop=%f:%f:%f:%f \"%s\"",
                contentUri, cropWidth, cropHeight, cropX, cropY, outputFilePath);

        // Execute FFmpeg command asynchronously
        FFmpegKit.executeAsync(ffmpegCommand, session -> {
            ReturnCode returnCode = session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
                // File URI for Capacitor
                Uri outputUri = Uri.fromFile(outputFile);
                JSObject result = new JSObject();
                result.put("outputfileUrl", outputUri.toString());
                call.resolve(result);
            } else {
                call.reject("Cropping failed: " + session.getAllLogsAsString());
            }
        });
    }
}
