import ballerina/log;
import ballerinax/aayu.mftg.as2.trigger as aayu;

// webhookSecret is the public key downloaded from MFT Gateway, set in Config.toml.
configurable aayu:ListenerConfig config = ?;

listener aayu:Listener aayuListener = new (config, 8090);

// Raises an alert when an outbound AS2 message fails, or is sent but never confirmed by the partner.
service aayu:FailedMessageService on aayuListener {

    remote function onMessageSendFailed(aayu:MessageFailedEvent payload) returns error? {
        log:printError("AS2 send failed", messageId = payload.messageId, partner = payload.partnerName,
                reason = payload.failureReason, attempts = payload.failures);
    }
}

service aayu:IncompleteMessageService on aayuListener {

    remote function onMessageSendIncomplete(aayu:MessageIncompleteEvent payload) returns error? {
        log:printWarn("AS2 send not confirmed", messageId = payload.messageId, partner = payload.partnerName,
                sentAt = payload.sentAt);
    }
}
