import { WebPlugin } from '@capacitor/core';

import type { VideoCropperPlugin } from './definitions';

export class VideoCropperWeb extends WebPlugin implements VideoCropperPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async getContacts(filter: string): Promise<{ results: any[] }>{
    console.log("filter", filter);
    return{
      results: [{
        firstName: 'Dummy',
        lastName: 'Entry',
        telephone: '123456'
      }]
    }

  }
}


