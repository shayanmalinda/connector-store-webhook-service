import ballerina/log;
import ballerinax/trigger.github;

configurable string webHookSecret = ?;

configurable github:ListenerConfig userInput = {
    "secret": webHookSecret
};
listener github:Listener webhookListener = new (userInput, 8090);

service github:ReleaseService on webhookListener {

    remote function onPublished(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }

    remote function onUnpublished(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }

    remote function onCreated(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }

    remote function onEdited(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }

    remote function onDeleted(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }

    remote function onPreReleased(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }
    
    remote function onReleased(github:ReleaseEvent payload) returns error? {
        log:printInfo("Received push-event-message ", eventPayload = payload);
    }

}
