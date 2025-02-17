import { WebPlugin } from '@capacitor/core';

import type { VideoCropperPlugin } from './definitions';

export class VideoCropperWeb extends WebPlugin implements VideoCropperPlugin {

  async cropVideo(options:  {fileUrl: string, cropX: number, cropY: number, 
    cropWidth: number, cropHeight: number }) : Promise<{ outputfileUrl: string}>{
      console.log("filter", options.fileUrl);

      return {
        outputfileUrl : "yes it works"
      }
    }

  async cropImage(options:  {fileUrl: string, cropX: number, cropY: number, 
    cropWidth: number, cropHeight: number }) : Promise<{ outputfileUrl: string}>{
      console.log("filter", options.fileUrl);

      return {
        outputfileUrl : "yes it works"
      }
    }

  async convertAndReplaceHEICWithJPG(options: {filePath : string}) : Promise<{ outputfileUrl: string}>{
    console.log("filter", options.filePath);

    return{
      outputfileUrl : "yes it works"
    }
  }

}


