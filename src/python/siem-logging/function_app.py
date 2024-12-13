import azure.functions as func
import datetime
import json
import logging
from collections import deque
from itertools import repeat

app = func.FunctionApp()

siem_keys_to_remove = ['pk', 'id', 'max_tokens', 'stream', 'temperature', 'top_p', 'isStreaming']

@app.function_name(name="replication-siem-logging")
@app.event_hub_message_trigger(arg_name="azeventhub", event_hub_name="central-logging", consumer_group="central-siem-replication", connection="EVENT_HUB")
@app.event_hub_output(arg_name="event", event_hub_name="siem-logging", connection="EVENT_HUB")
def replicate_siem_event(azeventhub: func.EventHubEvent, event: func.Out[str]):
    body = azeventhub.get_body()
    if body is not None:
        json_body = json.loads(body.decode('utf-8'))
        # remove keys the LLM needs but not the SIEM logging
        remove_keys(json_body, siem_keys_to_remove)
        event.set(json.dumps(json_body))

def remove_keys(d, keys_to_remove):
    if isinstance(d, dict):
        for key in keys_to_remove:
            if key in d:
                del d[key]
        for key, value in d.items():
            if isinstance(value, dict):
                remove_keys(value, keys_to_remove)
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        remove_keys(item, keys_to_remove)
