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

# Sync the repository information to the database.
#
# + repoName - Name of the repository
# + return - Error for any failure
isolated function syncRepository(string repoName) returns error? {

    // Fetching the releases to check whether if there's at least one release
    types:Release[] releases = check entity:getReleases(repoName);
    if releases.length() == 0 {
        log:printWarn(string `No releases found in the repository: ${repoName}`);
        return;
    }

    types:Repository|error repository = entity:getRepository(repoName);
    if repository is error {
        log:printError("Error while getting repository", repository, info = repository.toString());
        return;
    }

    do {
        // Fetching the Meta Data of the repository
        types:FileContent? metaData = check entity:getRepositoryFileContent(repository.name, META_DATA_FILE_NAME);
        if metaData is () {
            log:printWarn(string `Meta data not found in the repository: ${repository.name}`);
            check email:sendSyncFailureAlert({
                name: repository.name,
                reason: string `<b>${META_DATA_FILE_NAME}</b> file not found in the repository.`
            });
            return;
        }

        types:MetaDataContent|error metaDataContent = metaData.content.fromJsonStringWithType();
        if metaDataContent is error {
            log:printWarn(string `Error while reading meta data file in ${repository.name}`,
                        info = metaDataContent.toString());
            check email:sendSyncFailureAlert({
                name: repository.name,
                reason: string `Error while reading the <b><a href="${metaData.url}">${META_DATA_FILE_NAME}</a></b>.`
            });
            return;
        }
        string? metaContentWarning = validateMetaDataContent(metaDataContent, metaData.url);
        if metaContentWarning is string {
            check email:sendSyncFailureAlert({
                name: repository.name,
                reason: metaContentWarning
            });
            return;
        }

        // Clean up the existing labels of the repository
        check database:deleteLabels(repository.name);

        types:RepositoryInfo repositoryInfo = {
            ...repository,
            connectorName: metaDataContent?.name.toString(),
            owner: metaDataContent?.owner.toString(),
            category: metaDataContent?.category.toString(),
            documentationUrl: metaDataContent?.documentationUrl.toString(),
            description: metaDataContent?.description.toString(),
            status: metaDataContent?.status.toString(),
            labels: metaDataContent?.labels ?: []
        };
        // Inserting the repository to the database
        check database:insertRepositoryInfo(repositoryInfo);

        string[]? labels = metaDataContent?.labels;

        if labels is string[] && labels.length() > 0 {
            // Inserting the repository labels to the Database
            check database:insertLabels(repository.name, labels);
        }
    } on fail var err {
        log:printError(err.toString());
        check email:sendRuntimeErrorAlert(err);
    }
}

# Validate the content of the meta data file.
#
# + metaData - Meta data of the file
# + fileUrl - URL of the meta data file
# + return - Processed meta data content
isolated function validateMetaDataContent(types:MetaDataContent metaData, string fileUrl) returns string? {
    string metaContentWarning = "";
    foreach string key in metaData.keys() {
        if metaData.get(key) is () && key != "labels" {
            if metaContentWarning.length() === 0 {
                metaContentWarning += string `Below fields are missing in the <b><a href="${
                    fileUrl}">${META_DATA_FILE_NAME}</a></b>.<br><br>`;
            }
            metaContentWarning += string ` - ${key}<br><br>`;
        }
    }
    return metaContentWarning.length() > 0 ? metaContentWarning : ();
}
