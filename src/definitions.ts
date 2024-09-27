export interface VideoCropperPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
