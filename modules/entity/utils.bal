// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/graphql;
import ballerina/log;

# Log GraphQL query result field errors (if exists) in the given GraphQL error object array.
#
# + errorPosition - Position of error occurred
# + clientError - Graphql client error
# + return - Error as an error type
isolated function handleGraphQlResultError(string errorPosition, graphql:ClientError clientError) returns error {
    if clientError is graphql:PayloadBindingError {
        graphql:ErrorDetail[]? errors = clientError.detail().errors;
        log:printError(errorPosition + clientError.message(), clientError.cause(), info = errors);
    } else if clientError is graphql:InvalidDocumentError {
        graphql:ErrorDetail[]? errors = clientError.detail().errors;
        log:printError(errorPosition + clientError.message(), clientError.cause(), info = errors);
    } else if clientError is graphql:HttpError {
        anydata body = clientError.detail().body;
        log:printError(errorPosition + clientError.message(), clientError.cause(), info = body);
    } else {
        log:printError(errorPosition + clientError.message(), clientError.cause());
    }
    return clientError;
}
