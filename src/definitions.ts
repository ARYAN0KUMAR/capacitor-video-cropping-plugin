export interface VideoCropperPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  getContacts(options: { filter: string }): Promise<{ contacts: any[] }>;
  cropVideo(options: { fileUrl: string, cropX: number, cropY: number, 
    cropWidth: number, cropHeight: number }) : Promise<{croppedVideoBlob : string }>;
}
