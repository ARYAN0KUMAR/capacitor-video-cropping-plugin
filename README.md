# video-cropper-processor

This plugin handles video cropping and processing in ios and android

## Install

```bash
npm install video-cropper-processor
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`getContacts(...)`](#getcontacts)
* [`cropVideo(...)`](#cropvideo)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### getContacts(...)

```typescript
getContacts(options: { filter: string; }) => Promise<{ contacts: any[]; }>
```

| Param         | Type                             |
| ------------- | -------------------------------- |
| **`options`** | <code>{ filter: string; }</code> |

**Returns:** <code>Promise&lt;{ contacts: any[]; }&gt;</code>

--------------------


### cropVideo(...)

```typescript
cropVideo(options: { fileUrl: string; cropX: number; cropY: number; cropWidth: number; cropHeight: number; }) => Promise<{ croppedVideoBlob: string; }>
```

| Param         | Type                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| **`options`** | <code>{ fileUrl: string; cropX: number; cropY: number; cropWidth: number; cropHeight: number; }</code> |

**Returns:** <code>Promise&lt;{ croppedVideoBlob: string; }&gt;</code>

--------------------

</docgen-api>
