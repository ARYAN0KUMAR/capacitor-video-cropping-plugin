export interface VideoCropperPlugin {
  cropVideo(options: { fileUrl: string, cropX: number, cropY: number, 
    cropWidth: number, cropHeight: number }) : Promise<{outputfileUrl : string }>;
  cropImage(options: { fileUrl: string, cropX: number, cropY: number, 
    cropWidth: number, cropHeight: number }) : Promise<{outputfileUrl : string }>;
  convertAndReplaceHEICWithJPG(options: { filePath: string }) : Promise<{outputfileUrl : string}>;
}
