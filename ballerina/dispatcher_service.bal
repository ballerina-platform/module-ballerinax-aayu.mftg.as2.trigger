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

import ballerina/crypto;
import ballerina/http;
import ballerina/lang.array;
import ballerina/log;
import ballerinax/asyncapi.native.handler;

service class DispatcherService {
    *http:Service;
    private map<GenericServiceType> services = {};
    private handler:NativeHandler nativeHandler = new ();
    private string? webhookSecret;

    isolated function init(string? webhookSecret) {
        self.webhookSecret = webhookSecret;
    }

    isolated function addServiceRef(string serviceType, GenericServiceType genericService) returns error? {
        if (self.services.hasKey(serviceType)) {
            return error(string `Service of type ${serviceType} has already been attached`);
        }
        self.services[serviceType] = genericService;
    }

    isolated function removeServiceRef(string serviceType) returns error? {
        if (!self.services.hasKey(serviceType)) {
            return error(string `Cannot detach the service of type ${serviceType}. Service has not been attached to the listener before`);
        }
        _ = self.services.remove(serviceType);
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {
        error? verifyResult = self.verifyWebhookSignature(request, self.webhookSecret);
        if verifyResult is error {
            string reason = verifyResult.message().startsWith("Unauthorized:") ? verifyResult.message() : "Unauthorized: Malformed Request";
            log:printWarn("WEBHOOK_SIGNATURE_REJECTED", reason = reason, path = request.rawPath);
            http:Response r = new;
            r.statusCode = http:STATUS_UNAUTHORIZED;
            check caller->respond(r);
            return;
        }
        json payload = check request.getJsonPayload();
        string eventType = (check payload.eventType).toString();
        http:Response ackResponse = new;
        ackResponse.statusCode = http:STATUS_OK;
        check caller->respond(ackResponse);
        boolean|error dispatchResult = self.matchRemoteFunc(payload, eventType);
        if dispatchResult is error {
            log:printError("DISPATCH_FAILED", dispatchResult);
        } else if !dispatchResult {
            log:printWarn("NO_HANDLER_FOR_EVENT", eventIdentifier = eventType);
        }
    }

    private isolated function verifyWebhookSignature(http:Request request, string? webhookSecret) returns error? {
        if webhookSecret is () || webhookSecret.trim() == "" {
            return error("Unauthorized: Webhook Secret Not Configured");
        }
        if !request.hasHeader("mftg-wh-signature") {
            return error("Unauthorized: Missing Signature Header");
        }
        string receivedHeader = check request.getHeader("mftg-wh-signature");
        map<string> extractedHeaderValues = {};
        int headerCursor = 0;
        extractedHeaderValues["signature"] = receivedHeader.substring(headerCursor);
        headerCursor = receivedHeader.length();
        if !extractedHeaderValues.hasKey("signature") {
            return error("Unauthorized: Missing Header Component: signature");
        }
        string signature = extractedHeaderValues["signature"] ?: "";
        string payloadToHash = string `${check self.sortedJsonBody(check request.getJsonPayload())}`;
        crypto:PublicKey|error publicKey = self.rsaPublicKey(webhookSecret);
        if publicKey is error {
            return error("Unauthorized: Invalid Webhook Public Key");
        }
        byte[]|error receivedSignature = array:fromBase64(signature);
        if receivedSignature is error {
            return error("Unauthorized: Signature Mismatch");
        }
        boolean|crypto:Error signatureValid = crypto:verifyRsaSha256Signature(payloadToHash.toBytes(), receivedSignature, publicKey);
        if signatureValid is crypto:Error || !signatureValid {
            return error("Unauthorized: Signature Mismatch");
        }
    }

    private isolated function sortedJsonBody(json payload) returns string|error {
        map<json> fields = check payload.ensureType();
        string[] members = from string name in fields.keys().sort()
            select name.toJsonString() + ":" + self.compactJson(fields.get(name));
        return "{" + string:'join(",", ...members) + "}";
    }

    private isolated function compactJson(json value) returns string {
        if value is map<json> {
            string[] members = from var [name, member] in value.entries()
                select name.toJsonString() + ":" + self.compactJson(member);
            return "{" + string:'join(",", ...members) + "}";
        }
        if value is json[] {
            string[] items = from json item in value
                select self.compactJson(item);
            return "[" + string:'join(",", ...items) + "]";
        }
        return value.toJsonString();
    }

    private isolated function rsaPublicKey(string pem) returns crypto:PublicKey|error {
        if pem.includes("BEGIN CERTIFICATE") {
            return crypto:decodeRsaPublicKeyFromContent(pem.toBytes());
        }
        string[] lines = from string line in re `\n`.split(pem)
            where !line.trim().startsWith("-----")
            select line.trim();
        byte[] der = check array:fromBase64(string:'join("", ...lines));
        [int, int] keyInfo = check self.derElement(der, 0, 0x30);
        [int, int] algorithm = check self.derElement(der, keyInfo[0], 0x30);
        [int, int] bitString = check self.derElement(der, algorithm[0] + algorithm[1], 0x03);
        [int, int] rsaKey = check self.derElement(der, bitString[0] + 1, 0x30);
        [int, int] modulus = check self.derElement(der, rsaKey[0], 0x02);
        [int, int] exponent = check self.derElement(der, modulus[0] + modulus[1], 0x02);
        return crypto:buildRsaPublicKey(self.base64Url(der.slice(modulus[0], modulus[0] + modulus[1])), self.base64Url(der.slice(exponent[0], exponent[0] + exponent[1])));
    }

    private isolated function derElement(byte[] der, int offset, int tag) returns [int, int]|error {
        if offset + 2 > der.length() || der[offset] != tag {
            return error("Invalid RSA public key");
        }
        int length = der[offset + 1];
        int contentOffset = offset + 2;
        if length >= 128 {
            int count = length - 128;
            if count > 4 || contentOffset + count > der.length() {
                return error("Invalid RSA public key");
            }
            length = 0;
            foreach int i in 0 ..< count {
                length = length * 256 + der[contentOffset + i];
            }
            contentOffset += count;
        }
        if contentOffset + length > der.length() {
            return error("Invalid RSA public key");
        }
        return [contentOffset, length];
    }

    private isolated function base64Url(byte[] bytes) returns string {
        byte[] unsigned = bytes.length() > 1 && bytes[0] == 0 ? bytes.slice(1) : bytes;
        string encoded = re `[+]`.replaceAll(unsigned.toBase64(), "-");
        return re `=+$`.replace(re `[/]`.replaceAll(encoded, "_"), "");
    }

    private isolated function matchRemoteFunc(json payload, string eventType) returns boolean|error {
        if check self.matchRemoteFuncForReceivedMessage(payload) {
            return true;
        }
        if check self.matchRemoteFuncForSentMessage(payload) {
            return true;
        }
        if check self.matchRemoteFuncForFailedMessage(payload) {
            return true;
        }
        if check self.matchRemoteFuncForIncompleteMessage(payload) {
            return true;
        }
        return false;
    }

    private isolated function matchRemoteFuncForReceivedMessage(json payload) returns boolean|error {
        match payload.eventType {
            "MESSAGE.RECEIVED.SUCCESS" => {
                check self.executeRemoteFunc(payload, "MESSAGE.RECEIVED.SUCCESS", "ReceivedMessageService", "onMessageReceivedSuccess");
                return true;
            }
        }
        return false;
    }

    private isolated function matchRemoteFuncForSentMessage(json payload) returns boolean|error {
        match payload.eventType {
            "MESSAGE.SEND.SUCCESS" => {
                check self.executeRemoteFunc(payload, "MESSAGE.SEND.SUCCESS", "SentMessageService", "onMessageSendSuccess");
                return true;
            }
        }
        return false;
    }

    private isolated function matchRemoteFuncForFailedMessage(json payload) returns boolean|error {
        match payload.eventType {
            "MESSAGE.SEND.FAILED" => {
                check self.executeRemoteFunc(payload, "MESSAGE.SEND.FAILED", "FailedMessageService", "onMessageSendFailed");
                return true;
            }
        }
        return false;
    }

    private isolated function matchRemoteFuncForIncompleteMessage(json payload) returns boolean|error {
        match payload.eventType {
            "MESSAGE.SEND.INCOMPLETE" => {
                check self.executeRemoteFunc(payload, "MESSAGE.SEND.INCOMPLETE", "IncompleteMessageService", "onMessageSendIncomplete");
                return true;
            }
        }
        return false;
    }

    private isolated function executeRemoteFunc(json payload, string eventName, string serviceTypeStr, string eventFunction) returns error? {
        GenericServiceType? genericService = self.services[serviceTypeStr];
        if genericService is GenericServiceType {
            any boundEvent = check self.nativeHandler.bindEventPayload(genericService, eventFunction, payload);
            check self.nativeHandler.invokeRemoteFunction(boundEvent, eventName, eventFunction, genericService);
        } else {
            log:printDebug("SERVICE_NOT_ATTACHED", serviceType = serviceTypeStr, eventName = eventName);
        }
    }
}
