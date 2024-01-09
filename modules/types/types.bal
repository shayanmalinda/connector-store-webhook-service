// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.   

# Represent GitHub repository. 
public type Repository record {|
    # Repository name
    string name;
    # Repository url
    string url;
|};

# Content of the repository.
public type FileContent record {|
    # Decoded repository content
    string content;
    # URL of the file
    string url;
|};

# Metadata content of the repository.
public type MetaDataContent record {
    # Connector name
    string? name = ();
    # Owner of the connector
    string? owner = ();
    # Category of the connector
    string? category = ();
    # Documentation Url of the connector
    string? documentationUrl = ();
    # Description of the connector
    string? description = ();
    # Status of the connector
    string? status = ();
    # Labels of the connector
    string[]? labels?;
};

# Repository information.
public type RepositoryInfo record {
    *Repository;
    # Connector name
    string connectorName;
    # Owner of the connector
    string owner;
    # Category of the connector
    string category;
    # Documentation Url of the connector
    string documentationUrl;
    # Description of the connector
    string description;
    # Status of the connector
    string status;
    # Labels of the connector
    string[] labels = [];
};

# Repositories which are not following the meta data file structure.
public type ProblematicRepo record {|
    # Name of the repository
    string name;
    # Reason for failure
    string reason;
|};

# Information of a release.
public type Release record {
    # Release Id
    int id;
};
