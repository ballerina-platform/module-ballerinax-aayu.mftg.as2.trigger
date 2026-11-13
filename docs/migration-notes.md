# Migration notes: from `trigger.aayu.mftg.as2` to `aayu.mftg.as2.trigger`

`ballerinax/aayu.mftg.as2.trigger` replaces `ballerinax/trigger.aayu.mftg.as2` (last released as
0.10.0 from the `asyncapi-triggers` monorepo). The `ballerina/` source is generated from
`docs/spec/asyncapi.yaml` with the `asyncapi-tools` generator; changes go through the spec and a
regeneration, not hand edits to `ballerina/*.bal`. Every spec change and its source is listed in
[`docs/spec/sanitations.md`](spec/sanitations.md).

## Breaking change: package name and import

```ballerina
// before
import ballerinax/trigger.aayu.mftg.as2 as aayu;

// after
import ballerinax/aayu.mftg.as2.trigger as aayu;
```

## Breaking change: the listener verifies signatures

`trigger.aayu.mftg.as2` accepted every request without checking where it came from, and its
listener took only a port. The listener now takes a `ListenerConfig` first and checks the
`mftg-wh-signature` header with the public key you download from MFT Gateway:

```ballerina
// before
listener aayu:Listener aayuListener = new (8090);

// after
configurable aayu:ListenerConfig userInput = ?;   // webhookSecret = the public key, in Config.toml
listener aayu:Listener aayuListener = new (userInput, 8090);
```

Turn on **Generate Signature For Webhook Payload** for the webhook in MFT Gateway. Unsigned
deliveries are rejected.

## Breaking change: payload fields follow MFT Gateway's documented payloads

The records now match the example payloads in MFT Gateway's
[webhook documentation](https://aayutechnologies.com/docs/product/mft-gateway/integrations/webhook-integration/):

- Renamed: `messageAS2ID` -> `messageIdentifier`, `partnerAS2ID` -> `partnerIdentifier`,
  `stationAS2ID` -> `stationIdentifier`.
- Added: `service`, `messageId` and `timestamp` on every event, `sentAt` on failed events, and
  `failureReason` on sent events (sent as `null`).
- Removed: `subject` on failed events, which the documented payload doesn't have (use
  `messageSubject`).
- Sent, failed and incomplete events now require only the fields MFT Gateway's examples always
  carry; the rest are optional. Before, nearly every field was required, so those deliveries
  failed to bind and their handlers were never called.

## Handlers

All three remote functions keep their names and service types:
`ReceivedMessageService.onMessageReceivedSuccess`, `SentMessageService.onMessageSendSuccess` and
`FailedMessageService.onMessageSendFailed`. A fourth service type,
`IncompleteMessageService.onMessageSendIncomplete`, handles the newer `MESSAGE.SEND.INCOMPLETE`
event. Its handler parameter is now named `payload` instead of `event`, which doesn't affect your
code.

## Other changes

- The listener acknowledges a delivery before it runs your handler, so a slow or failing handler no
  longer makes MFT Gateway retry. Handler errors are logged.

## Test suite

`ballerina/tests` sends each of MFT Gateway's four documented AS2 example payloads, signed, to a
test listener and checks the right remote function runs. `bal test`: 5/5 passing.
