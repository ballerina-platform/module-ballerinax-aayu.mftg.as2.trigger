import ballerina/log;
import ballerinax/aayu.mftg.as2.trigger as aayu;

// webhookSecret is the public key downloaded from MFT Gateway, set in Config.toml.
configurable aayu:ListenerConfig config = ?;

listener aayu:Listener aayuListener = new (config, 8090);

// Writes one audit line per AS2 event, in or out, so every exchange with a partner is traceable.
service aayu:ReceivedMessageService on aayuListener {

    remote function onMessageReceivedSuccess(aayu:MessageReceivedEvent payload) returns error? {
        audit(payload.eventType, payload.messageId, payload.partnerName, payload.receivedAt);
    }
}

service aayu:SentMessageService on aayuListener {

    remote function onMessageSendSuccess(aayu:MessageSentEvent payload) returns error? {
        audit(payload.eventType, payload.messageId, payload.partnerName, payload.sentAt);
    }
}

service aayu:FailedMessageService on aayuListener {

    remote function onMessageSendFailed(aayu:MessageFailedEvent payload) returns error? {
        audit(payload.eventType, payload.messageId, payload.partnerName, payload.lastAttemptTime);
    }
}

service aayu:IncompleteMessageService on aayuListener {

    remote function onMessageSendIncomplete(aayu:MessageIncompleteEvent payload) returns error? {
        audit(payload.eventType, payload.messageId, payload.partnerName, payload.sentAt);
    }
}

function audit(string eventType, int messageId, string? partner, int at) {
    log:printInfo("AS2 audit", eventType = eventType, messageId = messageId, partner = partner, at = at);
}
