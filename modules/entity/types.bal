// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import connector_store_webhook_service.types;

import ballerina/graphql;

# GraphQL Repository response mapping.
type GitRepositoryResponse record {|
    *graphql:GenericResponseWithErrors;
    # GraphQL result of Repositories
    record {|
        # List of repositories
        types:Repository? gitRepository;
    |} data;
|};

# GraphQL Repository content response mapping.
type GitRepositoryFileContentResponse record {
    *graphql:GenericResponseWithErrors;
    # GraphQL result of Repository content information
    record {|
        # Repository content
        types:FileContent? gitRepositoryFileContent;
    |} data?;
};

# GraphQL Repository content response mapping.
type GitReleasesResponse record {|
    *graphql:GenericResponseWithErrors;
    # GraphQL result of Releases information
    record {|
        # List of releases
        types:Release[] gitReleases;
    |} data;
|};
