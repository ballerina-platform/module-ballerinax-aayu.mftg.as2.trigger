// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Configuration for the webhook listener, including the secret used to verify incoming requests.
public type ListenerConfig record {
    # The secret used to verify incoming webhook signatures.
    string webhookSecret?;
};

public type MessageReceivedEvent record {|
    # Service the event came from (as2 or sftp).
    string 'service;
    # Email address of the receiving party.
    string to;
    # Numeric identifier of the message.
    int messageId;
    # AS2 message identifier of the message.
    string messageIdentifier;
    # Subject of the message.
    string messageSubject;
    # Epoch milliseconds at which the event was created.
    int timestamp;
    # Identifier of the Partner.
    string partnerIdentifier;
    # Name of the Partner.
    string partnerName;
    # Identifier of the Station.
    string stationIdentifier;
    # Name of the Station.
    string stationName;
    # Paths of the message attachments.
    string[] attachments?;
    # Name of the bucket the message files are stored in.
    string bucketName;
    # Name of the tenant.
    string tenantName;
    # ID of the tenant.
    int tenantId;
    # Email associated with the tenant.
    string tenantEmail;
    # Event type.
    string eventType;
    # Epoch milliseconds at which the message was received.
    int receivedAt;
    json...;
|};

public type MessageSentEvent record {|
    # Service the event came from (as2 or sftp).
    string 'service;
    # Email address of the receiving party.
    string to?;
    # Numeric identifier of the message.
    int messageId;
    # AS2 message identifier of the message.
    string messageIdentifier?;
    # Subject of the message.
    string messageSubject?;
    # Epoch milliseconds at which the event was created.
    int timestamp?;
    # Identifier of the Partner.
    string partnerIdentifier?;
    # Name of the Partner.
    string partnerName?;
    # Identifier of the Station.
    string stationIdentifier?;
    # Name of the Station.
    string stationName?;
    # Paths of the message attachments.
    string[] attachments?;
    # Name of the bucket the message files are stored in.
    string bucketName?;
    # Name of the tenant.
    string tenantName?;
    # ID of the tenant.
    int tenantId?;
    # Email associated with the tenant.
    string tenantEmail?;
    # Event type.
    string eventType;
    # Epoch milliseconds at which the message was sent.
    int sentAt;
    # Always null for a sent message.
    string? failureReason?;
    json...;
|};

public type MessageFailedEvent record {|
    # Service the event came from (as2 or sftp).
    string 'service;
    # Email address of the receiving party.
    string to?;
    # Numeric identifier of the message.
    int messageId;
    # AS2 message identifier of the message.
    string messageIdentifier?;
    # Subject of the message.
    string messageSubject?;
    # Epoch milliseconds at which the event was created.
    int timestamp?;
    # Identifier of the Partner.
    string partnerIdentifier?;
    # Name of the Partner.
    string partnerName?;
    # Identifier of the Station.
    string stationIdentifier?;
    # Name of the Station.
    string stationName?;
    # Paths of the message attachments.
    string[] attachments?;
    # Name of the bucket the message files are stored in.
    string bucketName?;
    # Name of the tenant.
    string tenantName?;
    # ID of the tenant.
    int tenantId?;
    # Email associated with the tenant.
    string tenantEmail?;
    # Event type.
    string eventType;
    # Reason the send failed.
    string failureReason;
    # Number of failed attempts.
    int failures;
    # Epoch milliseconds of the last failed attempt.
    int lastAttemptTime;
    # Epoch milliseconds at which the send was first attempted.
    int sentAt?;
    json...;
|};

public type MessageIncompleteEvent record {|
    # Service the event came from (as2 or sftp).
    string 'service;
    # Email address of the receiving party.
    string to?;
    # Numeric identifier of the message.
    int messageId;
    # AS2 message identifier of the message.
    string messageIdentifier?;
    # Subject of the message.
    string messageSubject?;
    # Epoch milliseconds at which the event was created.
    int timestamp?;
    # Identifier of the Partner.
    string partnerIdentifier?;
    # Name of the Partner.
    string partnerName?;
    # Identifier of the Station.
    string stationIdentifier?;
    # Name of the Station.
    string stationName?;
    # Paths of the message attachments.
    string[] attachments?;
    # Name of the bucket the message files are stored in.
    string bucketName?;
    # Name of the tenant.
    string tenantName?;
    # ID of the tenant.
    int tenantId?;
    # Email associated with the tenant.
    string tenantEmail?;
    # Event type.
    string eventType;
    # Epoch milliseconds at which the outgoing message was recorded.
    int sentAt;
    json...;
|};
