package com.finitee.videoprocessing;
import android.net.Uri;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;


import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.Session;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import java.util.UUID;

import android.database.Cursor;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.content.Context;
import android.content.ContentResolver;

import android.graphics.Bitmap;
import android.graphics.ImageDecoder;
import android.os.Build;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import androidx.annotation.NonNull;

import android.util.Log;


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

//        String ffmpegCommand = String.format("-i \"%s\" -vf crop=%d:%d:%d:%d -c:v libx264 \"%s\"",
//                contentUri, cropWidth, cropHeight, cropX, cropY, outputFilePath);

        Log.d("VideoCropPlugin", "Output-Path: " + outputFilePath);
        Log.d("VideoCropPlugin", "File URL: " + fileUrl);
        Log.d("VideoCropPlugin", "Content URI: " + contentUri.toString());

        String ffmpegCommand = String.format(
                "-y -i \"%s\" -vf crop=%f:%f:%f:%f -c:v libx264 -c:a copy \"%s\"",
                contentUri,
                cropWidth, cropHeight,
                cropX, cropY,
                outputFilePath
        );


//
//        String ffmpegCommand = String.format("-i \"%s\" -vf crop=%f:%f:%f:%f \"%s\"",
//                contentUri, cropWidth, cropHeight, cropX, cropY, outputFilePath);

Log.d("VideoCropPlugin" ,"Cropx: "+ cropX );
        Log.d("VideoCropPlugin" ,"CropY: "+ cropY );
        // Execute FFmpeg command asynchronously
       FFmpegKit.executeAsync(ffmpegCommand, session -> {
           ReturnCode returnCode = session.getReturnCode();

Log.d("returnCode : " ," "+ returnCode);
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

    public static String convertHEICToJPG(Context context, String heicFilePath) throws IOException {
        // Step 1: Get the HEIC file as a URI
        File heicFile = new File(heicFilePath);
        if (!heicFile.exists()) {
            throw new IOException("HEIC file does not exist: " + heicFilePath);
        }

        Uri heicUri = Uri.fromFile(heicFile);

        // Step 2: Decode HEIC to Bitmap
        Bitmap bitmap;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            bitmap = ImageDecoder.decodeBitmap(ImageDecoder.createSource(context.getContentResolver(), heicUri));
        } else {
            bitmap = MediaStore.Images.Media.getBitmap(context.getContentResolver(), heicUri);
        }

        
        // Step 3: Create a new JPG file
        File jpgFile = new File(context.getCacheDir(), heicFile.getName().toLowerCase().replace(".heic", ".jpg"));
        FileOutputStream outputStream = new FileOutputStream(jpgFile);

        // Step 4: Compress the Bitmap into a JPG
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
        outputStream.flush();
        outputStream.close();

        return jpgFile.getAbsolutePath();
    }

    @PluginMethod
    public void convertAndReplaceHEICWithJPG(PluginCall call) {
        String filePath = call.getString("filePath");
        if (filePath == null) {
            call.reject("File path is required");
            return;
        }

        try {
            String jpgPath = convertHEICToJPG(getContext(), filePath);
            JSObject result = new JSObject();
            result.put("outputfileUrl", jpgPath);
            call.resolve(result);
        } catch (IOException e) {
            e.printStackTrace(); // Log the full stack trace for debugging
            call.reject("Failed to convert HEIC to JPG: " + e.getMessage(), e);
        }
    }


    @PluginMethod
    public void cropImage(PluginCall call) {
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
        String newFileName = UUID.randomUUID().toString() + ".jpg";
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
