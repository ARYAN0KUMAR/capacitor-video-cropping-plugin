import Foundation
import Capacitor
import ffmpegkit
//import FFmpegKit



/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(VideoCropperPlugin)
public class VideoCropperPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "VideoCropperPlugin"
    public let jsName = "VideoCropper"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "cropVideo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "cropImage", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "convertAndReplaceHEICWithJPG", returnType: CAPPluginReturnPromise),

    ]
    private let implementation = VideoCropper()
   
     @objc func cropVideo(_ call: CAPPluginCall) {
         guard let fileUrl = call.getString("fileUrl"),
               let cropX = call.getInt("cropX"),
               let cropY = call.getInt("cropY"),
               let cropWidth = call.getInt("cropWidth"),
               let cropHeight = call.getInt("cropHeight") else {
             call.reject("Invalid arguments")
             return
         }

         // Convert Capacitor URL to local file URL
         guard let videoUrl = URL(string: fileUrl),
               let inputFilePath = URL(string: videoUrl.absoluteString.replacingOccurrences(of: "capacitor://localhost/_capacitor_file_", with: "file://")) else {
             call.reject("Invalid file URL")
             return
         }
         
         
         // Generate a random filename
         let newFileName = UUID().uuidString + ".mp4"

         // Create a new URL by replacing the last path component
         let outputFilePath = inputFilePath.deletingLastPathComponent().appendingPathComponent(newFileName)



         // FFmpeg crop command
         let ffmpegCommand = "-i \(inputFilePath) -vf crop=\(cropWidth):\(cropHeight):\(cropX):\(cropY) \(outputFilePath)"
        
         // Run FFmpegKit command
         FFmpegKit.executeAsync(ffmpegCommand) { session in
             let returnCode = session?.getReturnCode()

             if ReturnCode.isSuccess(returnCode) {
                 // Convert to a Capacitor-accessible UR
                 print(outputFilePath);
 
                 
                call.resolve([
                    "outputfileUrl": outputFilePath.absoluteString // Ensure a string output
                ])
             } else {
                 let output = session?.getAllLogsAsString() ?? "Unknown error"
                 call.reject("Cropping failed: \(output)")
             }
         }
     }

    @objc func cropImage(_ call: CAPPluginCall) {
        guard let fileUrl = call.getString("fileUrl"),
              let cropX = call.getDouble("cropX"),
              let cropY = call.getDouble("cropY"),
              let cropWidth = call.getDouble("cropWidth"),
              let cropHeight = call.getDouble("cropHeight") else {
            call.reject("Invalid arguments")
            return
        }

        // Convert Capacitor URL to local file URL
        guard let imageUrl = URL(string: fileUrl),
              let inputFilePath = URL(string: imageUrl.absoluteString.replacingOccurrences(of: "capacitor://localhost/_capacitor_file_", with: "file://")) else {
            call.reject("Invalid file URL")
            return
        }
        
        
        // Generate a random filename
        let newFileName = UUID().uuidString + ".jpg"

        // Create a new URL by replacing the last path component
        let outputFilePath = inputFilePath.deletingLastPathComponent().appendingPathComponent(newFileName)

        
        // FFmpeg crop command
        let ffmpegCommand = "-i \(inputFilePath) -vf crop=\(cropWidth):\(cropHeight):\(cropX):\(cropY) \(outputFilePath)"
       
        // Run FFmpegKit command
        FFmpegKit.executeAsync(ffmpegCommand) { session in
            let returnCode = session?.getReturnCode()

            if ReturnCode.isSuccess(returnCode) {
                // Convert to a Capacitor-accessible UR
                print(outputFilePath);

                
               call.resolve([
                   "outputfileUrl": outputFilePath.absoluteString // Ensure a string output
               ])
            } else {
                let output = session?.getAllLogsAsString() ?? "Unknown error"
                call.reject("Cropping failed: \(output)")
            }
        }
    }
    
    @objc func convertAndReplaceHEICWithJPG(_ call: CAPPluginCall) {
        guard let filePathString = call.getString("filePath"),
              let fileUrl = URL(string: filePathString) else {
            call.reject("Invalid file URL")
            return
        }
        
        // Convert to a valid file path
        let filePath = fileUrl.path
        
        // FileManager instance
        let fileManager = FileManager.default

        // Check if the file exists
        guard fileManager.fileExists(atPath: filePath) else {
            call.reject("File does not exist at path: \(filePath)")
            return
        }
        
        // Load the HEIC image using ImageIO
        guard let imageSource = CGImageSourceCreateWithURL(fileUrl as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            call.reject("Failed to load HEIC image")
            return
        }
        
        // Get orientation from HEIC metadata
        let options = [kCGImageSourceShouldAllowFloat: true] as CFDictionary
        let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, options) as? [CFString: Any]
        let orientationRaw = properties?[kCGImagePropertyOrientation] as? Int ?? 1
        let correctedOrientation: Int
        switch orientationRaw {
        case 1:
            correctedOrientation = 8
        case 6:
            correctedOrientation = 3
        case 3:
            correctedOrientation = 1
        case 8:
            correctedOrientation = 2
        default:
            correctedOrientation = orientationRaw // Keep the original for other values
        }
        let orientation = UIImage.Orientation(rawValue: correctedOrientation) ?? .up

        print("orientation",orientation);
        print("orientationRaw", orientationRaw);
        // Create UIImage with correct orientation
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
        
        // Fix orientation by redrawing the image
        UIGraphicsBeginImageContextWithOptions(uiImage.size, false, uiImage.scale)
        uiImage.draw(in: CGRect(origin: .zero, size: uiImage.size))
        let correctedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage = correctedImage else {
            call.reject("Failed to correct image orientation")
            return
        }
        
        // Convert to JPEG data with reduced size
        guard let jpegData = finalImage.jpegData(compressionQuality: 0.8) else {
            call.reject("Failed to convert HEIC to JPEG")
            return
        }
        
        // Create the new file path with a .jpg extension
        let jpgFilePath = fileUrl.deletingPathExtension().appendingPathExtension("jpg").path
        
        do {
            // Write the JPEG data to the new file
            try jpegData.write(to: URL(fileURLWithPath: jpgFilePath))
            
            // Remove the original HEIC file
            //try fileManager.removeItem(atPath: filePath)
            
            // Resolve with the updated file path
            call.resolve([
                "outputfileUrl": jpgFilePath
            ])
        } catch {
            call.reject("Error during file operation: \(error.localizedDescription)")
        }
    }


}
