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

import ballerina/http;
import ballerina/io;
import ballerina/test;

// Signature of MESSAGE.SEND.SUCCESS.json made by Aayu's own @aayu-tech/json-sign 1.0.1 with TRIGGER_TEST_PRIVATE_KEY.
const PROVIDER_SIGNATURE = "P1O1YntYQKn/0y08D8wQAcT7f7668y7EdMtggl8HcAdXZSqSHMH4X+l7K46Ownz3BaaBCvOtDxV40z/otzqnOvuLWQCxx5cCy2vC86kpeEiE/xO412qlDiOFVel+BNfmjonp/CCu2SPWOjZ/ojHa990w0bHDrAXG6tL6l2V0Mckr8kKHOyB/GargMj06adNhoBhFb74rbmlJbNNEHuT2qIUy2NEg/9IDcI7s35t4Is0ZhtDEaMUdpuqeqoPtkFUWVJmJP59MtfN/FuSrkHjn0/xk3GaN+iHRh8qP60OxOxV82YxbjfqQTlq0Wfki+OSBoThWVNOQQT6iO2Emgv/J5Q==";

function sentEventBody() returns byte[]|error {
    return io:fileReadBytes(string `${TRIGGER_PAYLOAD_DIR}/MESSAGE.SEND.SUCCESS.json`);
}

@test:Config {}
function testProviderSignatureAccepted() returns error? {
    http:Response response = check triggerClient->post("/", check sentEventBody(),
            {"mftg-wh-signature": PROVIDER_SIGNATURE}, "application/json");
    test:assertEquals(response.statusCode, http:STATUS_OK);
}

@test:Config {}
function testUnsignedRequestRejected() returns error? {
    http:Response response = check triggerClient->post("/", check sentEventBody(), (), "application/json");
    test:assertEquals(response.statusCode, http:STATUS_UNAUTHORIZED);
}

@test:Config {}
function testTamperedBodyRejected() returns error? {
    map<json> payload = check (check string:fromBytes(check sentEventBody())).fromJsonStringWithType();
    payload["messageId"] = 1;
    http:Response response = check triggerClient->post("/", payload.toJsonString().toBytes(),
            {"mftg-wh-signature": PROVIDER_SIGNATURE}, "application/json");
    test:assertEquals(response.statusCode, http:STATUS_UNAUTHORIZED);
}
