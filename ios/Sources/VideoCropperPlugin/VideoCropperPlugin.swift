import Foundation
import Capacitor
import Contacts
import AVFoundation
import CoreImage
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
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getContacts", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "cropVideo", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = VideoCropper()

    @objc public func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc public func getContacts(_ call: CAPPluginCall) {
        let value = call.getString("filter") ?? ""
        let contactStore = CNContactStore()
        var contacts = [Any]()
        
        // Define the keys to fetch (name, phone numbers, email addresses)
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [Any]
        
        // Create a request to fetch these keys
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        
        // Request access to the contact store
        contactStore.requestAccess(for: .contacts) { granted, error in
            if granted {
                do {
                    // Fetch contacts based on the request
                    try contactStore.enumerateContacts(with: request) { (contact, stopPointer) in
                        // Check if the contact matches the filter value
                        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                        if fullName.lowercased().contains(value.lowercased()) || value.isEmpty {
                            var contactInfo = [String: Any]()
                            contactInfo["fullName"] = fullName
                            contactInfo["phoneNumbers"] = contact.phoneNumbers.map { $0.value.stringValue }
                            contactInfo["emailAddresses"] = contact.emailAddresses.map { $0.value as String }
                            contacts.append(contactInfo)
                        }
                    }
                    
                    // Resolve the plugin call with the fetched contacts
                    call.resolve([
                        "contacts": contacts
                    ])
                } catch {
                    // Handle error while fetching contacts
                    call.reject("Failed to fetch contacts", error.localizedDescription)
                }
            } else {
                // Handle case where permission was denied
                call.reject("Access to contacts was denied")
            }
        }
    }
    
//    @objc func cropVideo(_ call: CAPPluginCall) {
//            guard let fileUrl = call.getString("fileUrl"),
//                  let cropX = call.getFloat("cropX"),
//                  let cropY = call.getFloat("cropY"),
//                  let cropWidth = call.getFloat("cropWidth"),
//                  let cropHeight = call.getFloat("cropHeight") else {
//                call.reject("Invalid arguments")
//                return
//            }
//        
//        // Log the file URL
//           CAPLog.print("File URL: \(fileUrl)")
//
//        // Convert Capacitor URL to local file URL
//            guard let videoUrl = URL(string: fileUrl),
//                  let resolvedUrl = URL(string: videoUrl.absoluteString.replacingOccurrences(of: "capacitor://localhost/_capacitor_file_", with: "file://")) else {
//                call.reject("Invalid file URL")
//                return
//            }
//        
//        CAPLog.print("Resolved file URL: \(resolvedUrl)")
//
//        
//        let asset = AVAsset(url: resolvedUrl)
//            let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
//
//            // Define the cropping rectangle
//            let cropRect = CGRect(x: CGFloat(cropX), y: CGFloat(cropY), width: CGFloat(cropWidth), height: CGFloat(cropHeight))
//        
//
//            // Export cropped video
//           // cropAndExportVideo(asset: asset, cropRect: cropRect, outputUrl: outputUrl) { result in
//        convertToMP4(asset: asset, outputUrl: outputUrl) { result in
//                switch result {
//                case .success(let croppedVideoUrl):
//                    // Convert to Capacitor File URL
//                    let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                    let tempUrl = directoryUrl.appendingPathComponent(croppedVideoUrl.lastPathComponent)
//
//                    do {
//                        try FileManager.default.moveItem(at: croppedVideoUrl, to: tempUrl)
//                        call.resolve([
//                            "fileUrl": tempUrl.absoluteString
//                        ])
//                    } catch {
//                        call.reject("Error moving cropped video")
//                    }
//
//                case .failure(let error):
//                    call.reject("Cropping failed: \(error.localizedDescription)")
//                }
//            }
//        }

        private func cropAndExportVideo(asset: AVAsset, cropRect: CGRect, outputUrl: URL, completion: @escaping (Result<URL, Error>) -> Void) {
            let composition = AVMutableComposition()

            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                completion(.failure(NSError(domain: "VideoTrackNotFound", code: -1, userInfo: nil)))
                return
            }

            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)


            // Set up instructions for cropping
            let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = timeRange

            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            let transform = CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y)
            layerInstruction.setTransform(transform, at: .zero)
            instruction.layerInstructions = [layerInstruction]
            videoComposition.instructions = [instruction]

            // Set the crop size
            videoComposition.renderSize = cropRect.size

            // Export the cropped video
            let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
            exporter.outputURL = outputUrl
            exporter.outputFileType = .mp4
            exporter.videoComposition = videoComposition
            exporter.exportAsynchronously {
                switch exporter.status {
                case .completed:
                    completion(.success(outputUrl))
                case .failed:
                    if let error = exporter.error {
                        CAPLog.print("Export failed with error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                case .cancelled:
                    CAPLog.print("Export was cancelled")
                    completion(.failure(NSError(domain: "ExportCancelled", code: -1, userInfo: nil)))
                case .waiting:
                    CAPLog.print("Export is waiting to proceed")
                case .exporting:
                    CAPLog.print("Export is in progress")
                default:
                    CAPLog.print("Unknown export status: \(exporter.status.rawValue)")
                }
            }

        }
    
   
    @objc func cropVideo(_ call: CAPPluginCall) {
        guard let fileUrl = call.getString("fileUrl"),
              let cropX = call.getInt("cropX"),
              let cropY = call.getInt("cropY"),
              let cropWidth = call.getInt("cropWidth"),
              let cropHeight = call.getInt("cropHeight") else {
            call.reject("Invalid arguments")
            return
        }

        
        // Log the file URL
           CAPLog.print("File URL: \(fileUrl)")

        // Convert Capacitor URL to local file URL
            guard let videoUrl = URL(string: fileUrl),
                  let inputFilePath = URL(string: videoUrl.absoluteString.replacingOccurrences(of: "capacitor://localhost/_capacitor_file_", with: "file://")) else {
                call.reject("Invalid file URL")
                return
            }
        
        CAPLog.print("Resolved file URL: \(inputFilePath)")
        //let inputFilePath = URL(string: fileUrl)?.path ?? ""
        let outputFileName = UUID().uuidString + ".mp4"
        let outputFilePath = NSTemporaryDirectory().appending(outputFileName)

        // FFmpeg crop command
        let ffmpegCommand = "-i \(inputFilePath) -vf crop=\(cropWidth):\(cropHeight):\(cropX):\(cropY) \(outputFilePath)"
        
        // Run FFmpegKit command
        FFmpegKit.executeAsync(ffmpegCommand) { session in
            let returnCode = session?.getReturnCode()

            if ReturnCode.isSuccess(returnCode) {
                // Operation completed successfully
                call.resolve([
                    "fileUrl": "capacitor://localhost/_capacitor_file_\(outputFilePath)"
                ])
            } else {
                // Operation failed
                let output = session?.getAllLogsAsString() ?? "Unknown error"
                call.reject("Cropping failed: \(output)")
            }
        }
    }


}
