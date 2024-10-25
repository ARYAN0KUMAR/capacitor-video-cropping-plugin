import { WebPlugin } from '@capacitor/core';

import type { VideoCropperPlugin } from './definitions';

export class VideoCropperWeb extends WebPlugin implements VideoCropperPlugin {

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async cropVideo(options:  {fileUrl: string, cropX: number, cropY: number, 
    cropWidth: number, cropHeight: number }) : Promise<{ croppedVideoBlob: string}>{
      console.log("filter", options.fileUrl);

      return {
        croppedVideoBlob : "yes it works"
      }
    }

  async getContacts(options: { filter: string }): Promise<{ contacts: any[] }> {
    console.log("filter", options.filter);
    return {
      contacts: [{
        firstName: 'Dummy',
        lastName: 'Entry',
        telephone: '123456'
      }]
    };
  }
}


