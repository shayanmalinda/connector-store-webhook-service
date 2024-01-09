// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import connector_store_webhook_service.types;

import ballerina/log;
import ballerina/sql;

# Insert the repository to the database.
#
# + repositoryInfo - Repository info to be inserted
# + return - Error if any failure occurs
public isolated function insertRepositoryInfo(types:RepositoryInfo repositoryInfo) returns error? {
    sql:ExecutionResult|error result = dbClient->execute(insertRepositoryQuery(repositoryInfo));
    if result is error {
        log:printError("Error while inserting repository", result, info = result.toString());
        return result;
    }
}

# Check if the repository exists or not.
#
# + repoName - Name of the repository
# + return - Whether the repository exists or not
public isolated function isRepositoryExists(string repoName) returns boolean|error {
    types:RepositoryInfo|sql:Error repository = dbClient->queryRow(getRepositoryQuery(repoName));
    if repository is sql:NoRowsError {
        return false;
    } else if repository is sql:Error {
        log:printError("Error while checking repository", repository, info = repository.toString());
        return repository;
    } else {
        return true;
    }
}

# Delete existing labels.
#
# + repoName - Name of the repository
# + return - Error if any failure occurs
public isolated function deleteLabels(string repoName) returns error? {
    sql:ExecutionResult|error result = dbClient->execute(deleteLabelsQuery(repoName));
    if result is error {
        log:printError("Error while deleting labels", result, info = result.toString());
        return result;
    }
}

# Insert new labels.
#
# + repoName - Name of the repository
# + labels - List of labels in the repository
# + return - Error if any failure occurs
public isolated function insertLabels(string repoName, string[] labels) returns error? {
    sql:ParameterizedQuery[] insertQueries = from string label in labels
        select insertLabelQuery(repoName, label);
    sql:ExecutionResult[]|error result = dbClient->batchExecute(insertQueries);
    if result is error {
        log:printError("Error while inserting labels", result, info = result.toString());
        return result;
    }
}

# Delete repository.
#
# + repoName - Name of the repository
# + return - Error if any failure occurs
public isolated function deleteRepository(string repoName) returns error? {
    sql:ExecutionResult|error result = dbClient->execute(deleteRepositoryQuery(repoName));
    if result is error {
        log:printError("Error while deleting repository", result, info = result.toString());
        return result;
    }
}
