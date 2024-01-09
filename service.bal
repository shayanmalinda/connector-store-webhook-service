// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import connector_store_webhook_service.database;
import connector_store_webhook_service.email;
import connector_store_webhook_service.entity;
import connector_store_webhook_service.types;

import ballerina/log;
import ballerinax/trigger.github;

configurable string webhookSecret = ?;
configurable github:ListenerConfig userInput = {webhookSecret};

const META_DATA_FILE_NAME = ".connector-store/meta.json";

listener github:Listener webhookListener = new (userInput, 80);

service github:PushService on webhookListener {
    // TODO: check the status of the meta.json
    // TODO: check the commit.added and commit.removed
    remote function onPush(github:PushEvent payload) returns error? {

        github:Commit? headCommit = payload.head_commit;
        if headCommit is () {
            return;
        }
        string[]? modified = headCommit.modified;
        if modified is () {
            return;
        }
        if modified.indexOf(META_DATA_FILE_NAME) == -1 {
            return;
        }
        check syncRepository(payload.repository.name);
    }
}

service github:ReleaseService on webhookListener {

    remote function onReleased(github:ReleaseEvent payload) returns error? {
        do {
            boolean isRepositoryExists = check database:isRepositoryExists(payload.repository.name);
            if !isRepositoryExists {
                check syncRepository(payload.repository.name);
            }
        } on fail var err {
            log:printError(err.toString());
            check email:sendRuntimeErrorAlert(err);
        }
    }

    remote function onDeleted(github:ReleaseEvent payload) returns error? {
        do {
            types:Release[] releases = check entity:getReleases(payload.repository.name);
            if releases.length() == 0 {
                check database:deleteLabels(payload.repository.name);
                check database:deleteRepository(payload.repository.name);
            }
        } on fail var err {
            log:printError(err.toString());
            check email:sendRuntimeErrorAlert(err);
        }
    }

    remote function onPublished(github:ReleaseEvent payload) returns error? {
    }

    remote function onUnpublished(github:ReleaseEvent payload) returns error? {
    }

    remote function onCreated(github:ReleaseEvent payload) returns error? {
    }

    remote function onEdited(github:ReleaseEvent payload) returns error? {
    }

    remote function onPreReleased(github:ReleaseEvent payload) returns error? {
    }
}
