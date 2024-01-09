// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
// 
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

# Email record information.
type EmailRecord record {
    # Application UUID
    string appUuid;
    # Recipient list
    string[] to;
    # Carbon copy list 
    string[] cc?;
    # Sender email
    string frm;
    # Email subject
    string subject;
    # Id of html template using
    string templateId;
    # Content as key value pairs (keys are not case sensitive). Eg: {HEADER: "header", BODY: "This is the body"}
    map<string> contentKeyValPairs;
};
