// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import connector_store_webhook_service.types;

import ballerina/sql;

# Insert repository to database.
#
# + repositoryInfo - Repository info to be added
# + return - Parameterized query to add repository
isolated function insertRepositoryQuery(types:RepositoryInfo repositoryInfo) returns sql:ParameterizedQuery =>
    `INSERT INTO repository (
        repo_name,
        repo_url,
        connector_name,
        owner,
        description,
        category,
        documentation_url,
        status
    ) VALUES (
        ${repositoryInfo.name},
        ${repositoryInfo.url},
        ${repositoryInfo.connectorName},
        ${repositoryInfo.owner},
        ${repositoryInfo.description},
        ${repositoryInfo.category},
        ${repositoryInfo.documentationUrl},
        ${repositoryInfo.status}
    ) ON DUPLICATE KEY UPDATE
        repo_url = VALUES(repo_url),
        connector_name = VALUES(connector_name),
        owner = VALUES(owner),
        description = VALUES(description),
        category = VALUES(category),
        documentation_url = VALUES(documentation_url),
        status = VALUES(status)`;

# Get the repository info.
#
# + repoName - Name of the repository
# + return - Parameterized query to get repository
isolated function getRepositoryQuery(string repoName) returns sql:ParameterizedQuery =>
    `SELECT
        repo_name,
        repo_url,
        connector_name,
        owner,
        description,
        category,
        documentation_url,
        status
    FROM repository
        WHERE repo_name = ${repoName}`;

# Delete a repository.
#
# + repoName - Name of the repository
# + return - Parameterized query to delete a repository
isolated function deleteRepositoryQuery(string repoName) returns sql:ParameterizedQuery =>
    `DELETE FROM repository
        WHERE repo_name = ${repoName}`;

# Delete existing labels.
#
# + repoName - Name of the repository
# + return - Parameterized query to delete labels
isolated function deleteLabelsQuery(string repoName) returns sql:ParameterizedQuery =>
    `DELETE FROM label
        WHERE repo_name = ${repoName}`;

# Insert new labels.
#
# + repoName - Name of the repository
# + label - Label name
# + return - Parameterized query to insert the label
isolated function insertLabelQuery(string repoName, string label) returns sql:ParameterizedQuery =>
    `INSERT IGNORE INTO label (
        repo_name,
        label
    ) VALUES (
        ${repoName},
        ${label}
    )`;
