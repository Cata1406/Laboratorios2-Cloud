import base64
import json
import googleapiclient.discovery


def tag_with_creator(event, context):
    """Adds a custom metadata entry for a new virtual machine.
    Triggered by a Cloud Pub/Sub message containing a Compute Engine
    audit activity Stackdriver log message
    """
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    msg_json = json.loads(pubsub_message)
    proto_payload = msg_json['protoPayload']
    resource_name = proto_payload['resourceName']
    email = proto_payload['authenticationInfo']['principalEmail']
    
    # compute engine API
    compute = googleapiclient.discovery.build('compute', 'v1', cache_discovery=False)
    # full name is of the form
    # projects/$PROJ_NAME/zones/$ZONE/instances/$INST_NAME
    name_tokens = resource_name.split('/')
    project = name_tokens[1]
    zone = name_tokens[3]
    instance_name = name_tokens[5]
    
    # need to get current vm metadata before we can update it
    vm_details = compute.instances().get(
    project=project, zone=zone, instance=instance_name).execute()
    vm_metadata = vm_details['metadata']
    
    # add/replace metadata item
    _update_metadata(vm_metadata, 'creator', email)
    response = compute.instances().setMetadata(
    project=project, zone=zone, instance=instance_name,
    body=vm_metadata).execute()
    
    print('Updated metadata for resource %s' % resource_name)
    if item['key'] == key:
        item['value'] = value
    
    return vm_meta['items'].append({'key': key, 'value': value}) 