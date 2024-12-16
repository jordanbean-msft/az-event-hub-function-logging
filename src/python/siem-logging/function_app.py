import azure.functions as func
import datetime
import json
import logging
from collections import deque
from itertools import repeat

app = func.FunctionApp()

@app.function_name(name="replication-siem-logging")
@app.event_hub_message_trigger(arg_name="azeventhub", event_hub_name="central-logging", consumer_group="central-siem-replication", connection="EVENT_HUB")
@app.event_hub_output(arg_name="event", event_hub_name="siem-logging", connection="EVENT_HUB")
def replicate_siem_event(azeventhub: func.EventHubEvent, event: func.Out[str]):
    body = azeventhub.get_body()
    if body is not None:
        json_body = json.loads(body.decode('utf-8'))

        json_body = remove_keys(json_body)
        event.set(json.dumps(json_body))

def remove_keys(json_body):
    # Load fields to keep from JSON
    with open(file = 'fields_to_keep.json',
                  mode = 'r',
                  encoding = 'utf-8') as f:
        fields_to_keep_data = json.load(f)

    # Create a dictionary for quick lookup
    fields_to_keep_dict = {item['category']: item['fieldsToKeep'] for item in fields_to_keep_data}

    # Iterate through each record in the json_body
    for record in json_body['records']:
        category = record.get('category')
        if category in fields_to_keep_dict:
            allowed_fields = fields_to_keep_dict[category]
            keys_to_remove = [key for key in record.keys() if key not in allowed_fields]
            for key in keys_to_remove:
                del record[key]

    return json_body
