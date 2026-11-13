# Sanitations for the Aayu MFTG AsyncAPI specification

The spec was migrated from `asyncapi-triggers/asyncapi/aayu.mftg.as2/asyncapi.yml` (AsyncAPI 2.1.0) to AsyncAPI 3.0.0.

## Changes

1. Upgraded the document to AsyncAPI 3.0.0. The three `subscribe` channels became one `messages` channel with an `operations` block of `action: receive`.
2. `x-ballerina-event-type` moved from the message to the 3.0.0 message entry; event identifiers are unchanged (`eventType` in the body).
3. `info.externalDocs` now sits under `info`, where 3.0.0 expects it.
4. Aligned with the vendor webhook reference (https://aayutechnologies.com/docs/product/mft-gateway/integrations/webhook-integration/), checked 2026-10-05: added the `MESSAGE.SEND.INCOMPLETE` event, and renamed/added payload fields to match the documented payloads (`messageId`, `messageIdentifier`, `partnerIdentifier`, `stationIdentifier`, `service`, `timestamp`; `sentAt` on failures). The monorepo spec used older `*AS2ID` names and a `subject` field the docs do not show, and had a `tenantId.` typo in its required list.

5. Declared the webhook signature in `x-ballerina-auth`. The vendor documentation gives the header (`mftg-wh-signature`) and the scheme (SHA-256, pkcs1-sha256) and points to the `@aayu-tech/json-sign` npm module for verification. That module (https://unpkg.com/@aayu-tech/json-sign@1.0.1/index.js) defines what is signed: the payload with its top-level keys sorted, written by `JSON.stringify`, signed with `node-rsa` (default scheme `pkcs1-sha256`, RSA PKCS#1 v1.5 with SHA-256) and Base64 encoded. Hence `strategy: rsa`, `algorithm: sha256`, `encoding: base64` and `input: $sortedJsonBody` (ballerina-platform/ballerina-library#9351). The listener's `webhookSecret` takes the public key downloaded from the MFT Gateway UI. Signing is optional on the vendor side, but the generated listener rejects unsigned requests, so it must be enabled.

6. Required fields follow the documented example payloads (checked 2026-10-27). The examples for sent, failed and incomplete messages carry only a few fields (for example `service`, `eventType`, `messageId`, `sentAt` and `failureReason` for a sent message), while the spec required every field of a received message, so those deliveries failed to bind. Each event now requires exactly the fields its example carries; the others stay declared and optional. `failureReason`, which a sent message carries as `null`, is declared on it.
7. Each event has its own channel, and `x-ballerina-event-label` names its handler, so the service types and remote functions keep the names of the `trigger.aayu.mftg.as2` package this replaces: `ReceivedMessageService.onMessageReceivedSuccess`, `SentMessageService.onMessageSendSuccess` and `FailedMessageService.onMessageSendFailed`, plus `IncompleteMessageService.onMessageSendIncomplete` for the newer event.

## Verification

The four documented AS2 example payloads are the test payloads in `ballerina/tests/resources/trigger_payloads`. They were also signed with Aayu's own `@aayu-tech/json-sign` 1.0.1 and posted to the generated listener configured with the matching public key: all four were accepted and dispatched, and so was one reformatted with different whitespace; a changed field, a missing signature and a signature from another key were rejected with 401.

Checked live against MFT Gateway on 2026-10-28: a webhook with payload signing on, pointing at the listener configured with the downloaded webhook public key, delivered `MESSAGE.SEND.SUCCESS` and `MESSAGE.RECEIVED.SUCCESS` for a test message; both were accepted and dispatched to `onMessageSendSuccess` and `onMessageReceivedSuccess`, and the real payloads (including `attachments` as an array) bound to the generated records. An unsigned request to the same URL was rejected with 401.

## Not changed

- SFTP events use the same webhook but differ (no station fields; failure type is `MESSAGE.SEND.FAILURE`). Spec stays AS2 only to match the package name.
- The documented AS2 received example spells `Attachments` capitalised. The live delivery uses `attachments`, so the test payload uses the lowercase key; `attachments` stays optional for received events.
- Payload schemas are otherwise as in the monorepo.

Author: Dinuka Wickramasinghe
