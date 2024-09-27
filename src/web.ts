import { WebPlugin } from '@capacitor/core';

import type { VideoCropperPlugin } from './definitions';

export class VideoCropperWeb extends WebPlugin implements VideoCropperPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
