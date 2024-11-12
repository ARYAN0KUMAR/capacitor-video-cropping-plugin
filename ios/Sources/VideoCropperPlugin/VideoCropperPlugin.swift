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
        CAPPluginMethod(name: "cropVideo", returnType: CAPPluginReturnPromise)
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



}
