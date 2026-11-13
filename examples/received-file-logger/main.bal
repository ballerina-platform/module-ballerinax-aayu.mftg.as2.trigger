import ballerina/log;
import ballerinax/aayu.mftg.as2.trigger as aayu;

// webhookSecret is the public key downloaded from MFT Gateway, set in Config.toml.
configurable aayu:ListenerConfig config = ?;

listener aayu:Listener aayuListener = new (config, 8090);

// Logs each AS2 message received from a trading partner, with where its files were stored.
service aayu:ReceivedMessageService on aayuListener {

    remote function onMessageReceivedSuccess(aayu:MessageReceivedEvent payload) returns error? {
        string[] files = payload.attachments ?: [];
        log:printInfo("AS2 message received", partner = payload.partnerName, station = payload.stationName,
                subject = payload.messageSubject, messageId = payload.messageIdentifier,
                bucket = payload.bucketName, fileCount = files.length());
        foreach string file in files {
            log:printInfo("Attachment", messageId = payload.messageIdentifier, file = file);
        }
    }
}
