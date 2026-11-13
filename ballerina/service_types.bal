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

# Attachable service type exposing the ReceivedMessageService family of webhook events.
public type ReceivedMessageService service object {
    # Triggered on Message received success.
    # + payload - the MessageReceivedEvent webhook payload
    # + return - an error if handling the event fails
    remote function onMessageReceivedSuccess(MessageReceivedEvent payload) returns error?;
};

# Attachable service type exposing the SentMessageService family of webhook events.
public type SentMessageService service object {
    # Triggered on Message send success.
    # + payload - the MessageSentEvent webhook payload
    # + return - an error if handling the event fails
    remote function onMessageSendSuccess(MessageSentEvent payload) returns error?;
};

# Attachable service type exposing the FailedMessageService family of webhook events.
public type FailedMessageService service object {
    # Triggered on Message send failed.
    # + payload - the MessageFailedEvent webhook payload
    # + return - an error if handling the event fails
    remote function onMessageSendFailed(MessageFailedEvent payload) returns error?;
};

# Attachable service type exposing the IncompleteMessageService family of webhook events.
public type IncompleteMessageService service object {
    # Triggered on Message send incomplete.
    # + payload - the MessageIncompleteEvent webhook payload
    # + return - an error if handling the event fails
    remote function onMessageSendIncomplete(MessageIncompleteEvent payload) returns error?;
};

# The union of every service type that can be attached to this listener.
public type GenericServiceType ReceivedMessageService|SentMessageService|FailedMessageService|IncompleteMessageService;

