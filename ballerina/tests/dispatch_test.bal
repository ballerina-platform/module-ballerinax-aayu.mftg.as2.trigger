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
import ballerina/data.jsondata;
import ballerina/http;
import ballerina/io;
import ballerina/lang.runtime;
import ballerina/test;

const TRIGGER_TEST_PRIVATE_KEY = "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCj6RUDHBueZ9o5\np1XEgYFRPk6ev338Z3siunHhQc+Cf1aYbeoHigMUBb8bXnD2TSJMGfNky+Yu/WvR\naJ6gz2tEm1LYUEV+8LZP+zxDuD+w7ocYHOlLxNXOadJGea/vWOWp8S0j/SSW+KcZ\n3zOO6vYjv9GGIZ1XKjd9gScmNyMRoI9gyRL8AD33HSzKRqQyn5DPjXgXs5Do9LpR\nfStUQh2ASpcAa+OTMvpTxmfFz89AcBmefFyMhpcAwOkwKNo7rDC1eshBK1Z794LZ\nA1Zvke+uZDeBtJcpdnBP13ka8TEV0rtziPriNk5pn4PeSgJvrgBUPdd+7IN/gocK\nsYTtKE0XAgMBAAECggEAMQOajm8BzUkV5yakTZpCXtaIcQ0nMeqJ1lU1h5wD3uyQ\nKw23LWD2Ua70Ok1v7x8asfISp+IXJ5cNfjXQNZtA4uelitzaIz787YbduwxmM1To\nnevLUaZ/HvXi9MMfuq11I+/kRT5GCkU5xtFJXCPjzcXm9DqqD64moMeVuuZC/Npx\nYYFCz86uZTwH9avbKhWhV8jH0cTgVJkwXA1vLe44feyOVMl/Ofv73SX2aZGJ9noN\n5ipDT62A4CPUwqKUbZpTHCWDUnocAUxmBciZEnj5oeglkrtFGNsl4hfcNtZ5+6e6\nZUZczOrpOQSrIhZOd8jdrEl14n6RPgZTjJtyZnqBkQKBgQDTwp0MUsEshIzXuYvq\n3FnGFauJOplIJpHHavmF+Xn6TDQI0DwE0KlOd/pJzVowsI9HlaTMQEV1/8HQarvL\nKGBCsdf7pjjFAlNmCG+E2eb81poEC3jTVuds1t0xDnJ/yL8tSY6/ShalFxRSmeRz\nC/GQcDabEWLKICKJOVAf5FzAJwKBgQDGJ1z2RdgpnxpJdNHVmW5/LzzqLGepM/Yp\nYEaxAivE6ePoQkgF9JKLAp2w1hJwYMKYM8cUH3AkPdqRVDz3j05MQb3pY7SZH+t7\n51gulBR7ecx3uug5NDhblcw5ZWywDvJPQnQ2jF1DoPYwSLwAyZBAnTgYdbWebdxe\nazjfnGgxkQKBgQCnJqA2wP/QdxSBl+mUyrhmPma3nLSvmhpKEevCUAlzhEEyj8RA\nfMCXuuaq6Nh/RG7kr3905mqt2OMQ858mnslU+/KjpjJ7d/mCubflYucMvwy1kqSe\nFaP5aqUQevnwWfJl+gEeh4nWaKBXDzifg1b7j0fbIV8ccz8vmDjh460+0wKBgHZk\njHmkr4vmwPkEsF70Jn4dRkMQNvt0zW5ZVMNr7aTgrkhWWdwdDfW6oWdH8IpudbYk\nsZzHT+SHhHDyqN6tI/YSDZtF9GDNHpDQX/KsjTRdSJp89UVAey/VZ8kfXXov4/0R\nUohJA2xl3tJoktPRmrvQc/TBV7uKHnHXlIqeU+7RAoGBAMQINLReFs+kbVTP6Uo/\nUtMjlVJI5mcyYdAw4qaqirm6+dXh6RlyAjV8qN8KW5+Zyu3+lQ4ga4DWzSWbbMFG\nWJMDDiS1CeFWwQiBahR5ESt048mQ8OKxM+xP4xA9ao61LfT2koZ5Um5T4p0b3IW7\ndc+jvxmU0n66FG07r/uOfNWV\n-----END PRIVATE KEY-----";
const TRIGGER_TEST_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo+kVAxwbnmfaOadVxIGB\nUT5Onr99/Gd7Irpx4UHPgn9WmG3qB4oDFAW/G15w9k0iTBnzZMvmLv1r0WieoM9r\nRJtS2FBFfvC2T/s8Q7g/sO6HGBzpS8TVzmnSRnmv71jlqfEtI/0klvinGd8zjur2\nI7/RhiGdVyo3fYEnJjcjEaCPYMkS/AA99x0sykakMp+Qz414F7OQ6PS6UX0rVEId\ngEqXAGvjkzL6U8Znxc/PQHAZnnxcjIaXAMDpMCjaO6wwtXrIQStWe/eC2QNWb5Hv\nrmQ3gbSXKXZwT9d5GvExFdK7c4j64jZOaZ+D3koCb64AVD3XfuyDf4KHCrGE7ShN\nFwIDAQAB\n-----END PUBLIC KEY-----";
const TRIGGER_TEST_PORT = 9091;
const TRIGGER_PAYLOAD_DIR = "tests/resources/trigger_payloads";

isolated map<boolean> triggerFired = {};
isolated map<json> boundPayloads = {};
isolated map<json> boundJson = {};

listener Listener triggerTestListener = check new ({webhookSecret: TRIGGER_TEST_PUBLIC_KEY}, TRIGGER_TEST_PORT);

final http:Client triggerClient = check new (string `http://localhost:${TRIGGER_TEST_PORT}`);

service ReceivedMessageService on triggerTestListener {
    isolated remote function onMessageReceivedSuccess(MessageReceivedEvent payload) returns error? {
        readonly & json received = jsondata:toJson(payload).cloneReadOnly();
        lock {
            boundJson["ReceivedMessageService.onMessageReceivedSuccess"] = received;
        }
        lock {
            triggerFired["ReceivedMessageService.onMessageReceivedSuccess"] = true;
        }
    }
}

service SentMessageService on triggerTestListener {
    isolated remote function onMessageSendSuccess(MessageSentEvent payload) returns error? {
        readonly & json received = jsondata:toJson(payload).cloneReadOnly();
        lock {
            boundJson["SentMessageService.onMessageSendSuccess"] = received;
        }
        lock {
            triggerFired["SentMessageService.onMessageSendSuccess"] = true;
        }
    }
}

service FailedMessageService on triggerTestListener {
    isolated remote function onMessageSendFailed(MessageFailedEvent payload) returns error? {
        readonly & json received = jsondata:toJson(payload).cloneReadOnly();
        lock {
            boundJson["FailedMessageService.onMessageSendFailed"] = received;
        }
        lock {
            triggerFired["FailedMessageService.onMessageSendFailed"] = true;
        }
    }
}

service IncompleteMessageService on triggerTestListener {
    isolated remote function onMessageSendIncomplete(MessageIncompleteEvent payload) returns error? {
        readonly & json received = jsondata:toJson(payload).cloneReadOnly();
        lock {
            boundJson["IncompleteMessageService.onMessageSendIncomplete"] = received;
        }
        lock {
            triggerFired["IncompleteMessageService.onMessageSendIncomplete"] = true;
        }
    }
}

isolated function sendSignedTriggerWebhook(string eventIdentifier) returns http:Response|error {
    byte[] body = check io:fileReadBytes(string `${TRIGGER_PAYLOAD_DIR}/${eventIdentifier}.json`);
    string bodyText = check string:fromBytes(body);
    string payloadToHash = string `${check sortedJsonBody(check bodyText.fromJsonString())}`;
    crypto:PrivateKey privateKey = check crypto:decodeRsaPrivateKeyFromContent(TRIGGER_TEST_PRIVATE_KEY.toBytes());
    byte[] computedDigest = check crypto:signRsaSha256(payloadToHash.toBytes(), privateKey);
    string computedSignature = computedDigest.toBase64();
    map<string> headers = {
        "mftg-wh-signature": string `${computedSignature}`
    };
    return triggerClient->post("/", body, headers, "application/json");
}

isolated function sortedJsonBody(json payload) returns string|error {
    map<json> fields = check payload.ensureType();
    string[] members = from string name in fields.keys().sort()
        select name.toJsonString() + ":" + compactJson(fields.get(name));
    return "{" + string:'join(",", ...members) + "}";
}

isolated function compactJson(json value) returns string {
    if value is map<json> {
        string[] members = from var [name, member] in value.entries()
            select name.toJsonString() + ":" + compactJson(member);
        return "{" + string:'join(",", ...members) + "}";
    }
    if value is json[] {
        string[] items = from json item in value
            select compactJson(item);
        return "[" + string:'join(",", ...items) + "]";
    }
    return value.toJsonString();
}

function waitForDispatch(string trackerKey) returns boolean {
    foreach int i in 0 ..< 20 {
        lock {
            if triggerFired[trackerKey] ?: false {
                return true;
            }
        }
        runtime:sleep(0.05);
    }
    return false;
}

function boundJsonOf(string trackerKey) returns json {
    lock {
        return boundJson[trackerKey].clone();
    }
}

function deliveredEvent(json bound, json fixture) returns json {
    return fixture is json[] && fixture.length() == 1 && bound is map<json>
        ? fixture[0] : fixture;
}

function assertBindsFixture(json bound, json fixture, string at) {
    if fixture is map<json> {
        test:assertTrue(bound is map<json>, string `${at} should have bound to an object`);
        if bound is map<json> {
            foreach [string, json] [key, value] in fixture.entries() {
                assertBindsFixture(bound[key], value, string `${at}.${key}`);
            }
        }
    } else if fixture is json[] {
        test:assertTrue(bound is json[] && bound.length() == fixture.length(),
                string `${at} should have bound to an array of ${fixture.length()}`);
        if bound is json[] && bound.length() == fixture.length() {
            foreach int i in 0 ..< fixture.length() {
                assertBindsFixture(bound[i], fixture[i], string `${at}[${i}]`);
            }
        }
    } else if fixture is int|float|decimal && bound is int|float|decimal {
        test:assertEquals(<decimal>bound, <decimal>fixture,
                string `${at} should have bound unchanged`);
    } else {
        test:assertEquals(bound, fixture,
                string `${at} should have bound unchanged`);
    }
}

@test:Config {}
function testMessageReceivedSuccessDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("MESSAGE.RECEIVED.SUCCESS");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("ReceivedMessageService.onMessageReceivedSuccess"), "ReceivedMessageService.onMessageReceivedSuccess should have fired");
    json fixture = check io:fileReadJson(string `${TRIGGER_PAYLOAD_DIR}/MESSAGE.RECEIVED.SUCCESS.json`);
    json received = boundJsonOf("ReceivedMessageService.onMessageReceivedSuccess");
    assertBindsFixture(received, deliveredEvent(received, fixture), "MessageReceivedEvent");
}

@test:Config {}
function testMessageSendSuccessDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("MESSAGE.SEND.SUCCESS");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("SentMessageService.onMessageSendSuccess"), "SentMessageService.onMessageSendSuccess should have fired");
    json fixture = check io:fileReadJson(string `${TRIGGER_PAYLOAD_DIR}/MESSAGE.SEND.SUCCESS.json`);
    json received = boundJsonOf("SentMessageService.onMessageSendSuccess");
    assertBindsFixture(received, deliveredEvent(received, fixture), "MessageSentEvent");
}

@test:Config {}
function testMessageSendFailedDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("MESSAGE.SEND.FAILED");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("FailedMessageService.onMessageSendFailed"), "FailedMessageService.onMessageSendFailed should have fired");
    json fixture = check io:fileReadJson(string `${TRIGGER_PAYLOAD_DIR}/MESSAGE.SEND.FAILED.json`);
    json received = boundJsonOf("FailedMessageService.onMessageSendFailed");
    assertBindsFixture(received, deliveredEvent(received, fixture), "MessageFailedEvent");
}

@test:Config {}
function testMessageSendIncompleteDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("MESSAGE.SEND.INCOMPLETE");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("IncompleteMessageService.onMessageSendIncomplete"), "IncompleteMessageService.onMessageSendIncomplete should have fired");
    json fixture = check io:fileReadJson(string `${TRIGGER_PAYLOAD_DIR}/MESSAGE.SEND.INCOMPLETE.json`);
    json received = boundJsonOf("IncompleteMessageService.onMessageSendIncomplete");
    assertBindsFixture(received, deliveredEvent(received, fixture), "MessageIncompleteEvent");
}

@test:Config {}
function testSortedJsonBody() returns error? {
    json payload = {"z": 1, "a": {"y": true, "b": [1, "x", null]}, "m": "s"};
    test:assertEquals(check sortedJsonBody(payload),
            "{\"a\":{\"y\":true,\"b\":[1,\"x\",null]},\"m\":\"s\",\"z\":1}");
}

