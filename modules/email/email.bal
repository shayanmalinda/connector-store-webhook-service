// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
// 
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import connector_store_webhook_service.types;

import ballerina/http;
import ballerina/log;
import ballerina/time;

configurable string emailEndpointUrl = ?;
configurable string appUuid = ?;
configurable string fromEmail = ?;
configurable string documentationUrl = ?;
configurable string[] syncFailureToRecipients = ?;
configurable string[] syncFailureCcRecipients = ?;
configurable string[] runtimeFailureToRecipients = ?;
configurable string[] runtimeFailureCcRecipients = ?;

@display {
    label: "Email Notifications Service",
    id: "infra/email-notifications-service"
}
final http:Client clientEndpoint = check new (emailEndpointUrl);

# Send email if there's any issue in the sync.
#
# + repo - List of problematic rep
# + return - Error if any issue occurs
public isolated function sendSyncFailureAlert(types:ProblematicRepo repo) returns error? {

    string tableData = string `<tr>
            <th style="padding: 5px 5px;">Repository</th>
            <th style="padding: 5px 5px;">Reason for failure</th>
        </tr>
        `;

    tableData = tableData + string `
            <tr>
                <td style="padding: 5px 5px;">${repo.name}</td>
                <td style="padding: 5px 5px;">${repo.reason}</td>
            </tr>`;

    map<string> contentKeyValPairs = {
        table_data: tableData,
        documentation_url: documentationUrl
    };

    EmailRecord finalPayload = {
        appUuid,
        to: syncFailureToRecipients,
        cc: syncFailureCcRecipients,
        frm: fromEmail,
        subject: "[Connector Store Webhook Service] Error while syncing connector store data",
        templateId: "syncFailureAlert",
        contentKeyValPairs
    };

    json _ = check clientEndpoint->/send\-smtp\-email.post(finalPayload);

    log:printInfo("Sync failure alert was sent",
        to = finalPayload.to.toString(),
        cc = finalPayload.cc.toString()
    );
}

# Send email if there's any runtime failure in the sync.
#
# + err - Runtime error occurred
# + return - Error if any failure occurs
public isolated function sendRuntimeErrorAlert(error err) returns error? {

    map<string> contentKeyValPairs = {
        time: time:utcToString(time:utcNow()).toString(),
        message: err.message(),
        stacktrace: err.stackTrace().toString(),
        payload: err.toString()
    };

    EmailRecord finalPayload = {
        appUuid,
        to: runtimeFailureToRecipients,
        cc: runtimeFailureCcRecipients,
        frm: fromEmail,
        subject: "[Connector Store Webhook Service] Runtime error while syncing the data",
        templateId: "generalServiceError",
        contentKeyValPairs
    };

    json _ = check clientEndpoint->/send\-smtp\-email.post(finalPayload);

    log:printInfo(string `Runtime failure alert was sent`,
        to = finalPayload.to.toString(),
        cc = finalPayload.cc.toString()
    );
}
