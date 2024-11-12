# video-cropper-processor

This plugin handles video cropping and processing in ios and android

## Install

```bash
npm install video-cropper-processor
npx cap sync
```

## API

<docgen-index>

* [`cropVideo(...)`](#cropvideo)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### cropVideo(...)

```typescript
cropVideo(options: { fileUrl: string; cropX: number; cropY: number; cropWidth: number; cropHeight: number; }) => Promise<{ outputfileUrl: string; }>
```

| Param         | Type                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| **`options`** | <code>{ fileUrl: string; cropX: number; cropY: number; cropWidth: number; cropHeight: number; }</code> |

**Returns:** <code>Promise&lt;{ outputfileUrl: string; }&gt;</code>

--------------------

</docgen-api>
