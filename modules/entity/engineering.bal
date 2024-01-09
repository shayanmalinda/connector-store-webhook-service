// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import connector_store_webhook_service.types;

import ballerina/graphql;
import ballerina/io;
import ballerina/log;
import ballerina/mime;

configurable string orgName = ?;

# Get repository.
#
# + repoName - Name of the repository
# + return - List of repositories
public isolated function getRepository(string repoName) returns types:Repository|error {
    string query = string `
        query repositoryQuery($orgName: String!, $owner: String!, $repoName: String!) {
            gitRepository(orgName: $orgName, owner: $owner, repoName: $repoName) {
                name
                url
            }
        }`;

    GitRepositoryResponse|graphql:ClientError response = entityClient->execute(query, {
        orgName,
        owner: orgName,
        repoName
    });

    if response is graphql:ClientError {
        return handleGraphQlResultError("getRepository(): ", response);
    }

    types:Repository? repository = response.data.gitRepository;
    return repository is ()
        ? error(string `Repository not found: ${repoName}`)
        : repository;
}

# Get content of the repository.
#
# + filePath - File path
# + repoName - Name of the repository
# + return - Content of the repository
public isolated function getRepositoryFileContent(string repoName, string filePath) returns types:FileContent|error? {
    string query = string `
        query repositoryContentQuery($orgName: String!, $owner: String!, $repoName: String!, $filePath: String!) {
            gitRepositoryFileContent(orgName: $orgName, owner: $owner, repoName: $repoName, filePath: $filePath) {
                content
                url
            }
        }`;

    GitRepositoryFileContentResponse|graphql:ClientError response = entityClient->execute(query, {
        orgName,
        owner: orgName,
        repoName,
        filePath
    });
    if response is graphql:ClientError {
        return handleGraphQlResultError("getRepositoryContent(): ", response);
    }
    types:FileContent? fileContent = response.data?.gitRepositoryFileContent;
    if fileContent is () {
        return fileContent;
    }

    string|byte[]|io:ReadableByteChannel|mime:DecodeError decodedContent = mime:base64Decode(fileContent.content);
    if decodedContent is string {
        fileContent.content = decodedContent;
        return fileContent;
    } else if decodedContent is error {
        log:printError("Error occurred while decoding the content of the file.",
        decodedContent, info = decodedContent.toString());
    }
    return error("Error occurred while decoding the content of the file.");
}

# Get the releases in the repository.
#
# + repoName - Name of the repository
# + return - List of releases
public isolated function getReleases(string repoName) returns types:Release[]|error {
    string query = string `
        query releasesQuery($orgName: String!, $owner: String!, $repoName: String!, $limit: Int, $page: Int) {
            gitReleases(orgName: $orgName, owner: $owner, repoName: $repoName, limit: $limit, page: $page) {
                id
            }
        }`;

    GitReleasesResponse|graphql:ClientError response = entityClient->execute(query, {
        orgName,
        owner: orgName,
        repoName,
        'limit: 1,
        page: 1
    });
    if response is graphql:ClientError {
        return handleGraphQlResultError("getReleases(): ", response);
    }
    return response.data.gitReleases;
}
