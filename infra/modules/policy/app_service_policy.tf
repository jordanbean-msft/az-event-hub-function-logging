resource "azurerm_policy_definition" "app_service_diagnostic_logging_event_hub_policy" {
  name                = "app-service-diagnostic-logging-event-hub-policy"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Enable logging by category group for App Service (microsoft.web/sites) to Event Hub"
  management_group_id = data.azurerm_management_group.management_group.id
  metadata            = <<METADATA
    {
    "category": "Monitoring"
    }

METADATA


  policy_rule = <<POLICY_RULE
{
    "if": {
            "allOf": [
                {
                    "field": "type",
                    "equals": "Microsoft.Web/sites"
                },
                {
                    "value": "[field('kind')]",
                    "notContains": "functionapp"
                },
                {
                    "anyOf": [
                        {
                            "value": "[parameters('resourceLocation')]",
                            "equals": ""
                        },
                        {
                            "field": "location",
                            "equals": "[parameters('resourceLocation')]"
                        }
                    ]
                }
            ]
        },
        "then": {
            "effect": "[parameters('effect')]",
            "details": {
                "type": "Microsoft.Insights/diagnosticSettings",
                "name": "[parameters('diagnosticSettingName')]",
                "evaluationDelay": "AfterProvisioning",
                "existenceCondition": {
                    "allOf": [
                        {
                            "count": {
                                "field": "Microsoft.Insights/diagnosticSettings/logs[*]",
                                "where": {
                                    "allOf": [
                                        {
                                            "field": "Microsoft.Insights/diagnosticSettings/logs[*].enabled",
                                            "equals": "[parameters('logsEnabled')]"
                                        },
                                        {
                                            "field": "microsoft.insights/diagnosticSettings/logs[*].categoryGroup",
                                            "equals": "allLogs"
                                        }
                                    ]
                                }
                            },
                            "equals": 1
                        },
                        {
                            "field": "Microsoft.Insights/diagnosticSettings/metrics.enabled",
                            "equals": "[parameters('metricsEnabled')]"
                        },
                        {
                            "field": "Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId",
                            "matchInsensitively": "[parameters('eventHubAuthorizationRuleId')]"
                        },
                        {
                            "field": "Microsoft.Insights/diagnosticSettings/eventHubName",
                            "matchInsensitively": "[parameters('eventHubName')]"
                        }
                    ]
                },
                "roleDefinitionIds": [
                    "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
                    "/providers/microsoft.authorization/roleDefinitions/f526a384-b230-433a-b45c-95f59c4a2dec"
                ],
                "deployment": {
                    "properties": {
                        "mode": "Incremental",
                        "template": {
                            "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                            "contentVersion": "1.0.0.0",
                            "parameters": {
                                "resourceName": {
                                    "type": "String"
                                },
                                "eventHubAuthorizationRuleId": {
                                    "type": "string"
                                },
                                "eventHubName": {
                                    "type": "string"
                                },
                                "resourceLocation": {
                                    "type": "String"
                                },
                                "diagnosticSettingName": {
                                    "type": "String"
                                },
                                "metricsEnabled": {
                                    "type": "String"
                                },
                                "logsEnabled": {
                                    "type": "String"
                                }
                            },
                            "variables": {},
                            "resources": [
                                {
                                    "type": "Microsoft.Web/sites/providers/diagnosticSettings",
                                    "apiVersion": "2021-05-01-preview",
                                    "name": "[concat(parameters('resourceName'), '/', 'Microsoft.Insights/', parameters('diagnosticSettingName'))]",
                                    "location": "[parameters('resourceLocation')]",
                                    "dependsOn": [],
                                    "properties": {
                                        "eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
                                        "eventHubName": "[parameters('eventHubName')]",
                                        "metrics": [
                                            {
                                                "category": "AllMetrics",
                                                "enabled": "[parameters('metricsEnabled')]",
                                                "retentionPolicy": {
                                                    "days": 0,
                                                    "enabled": false
                                                },
                                                "timeGrain": null
                                            }
                                        ],
                                        "logs": [
                                            {
                                                "categoryGroup": "allLogs",
                                                "enabled": "[parameters('logsEnabled')]"
                                            }
                                        ]
                                    }
                                }
                            ],
                            "outputs": {
                                "policy": {
                                    "type": "string",
                                    "value": "[concat('Diagnostic setting ', parameters('diagnosticSettingName'), ' for type Web App (not functionapps) (Microsoft.Web/sites), resourceName ', parameters('resourceName'), ' to EventHub ', parameters('eventHubAuthorizationRuleId'), ':', parameters('eventHubName'), ' configured')]"
                                }
                            }
                        },
                        "parameters": {
                            "eventHubAuthorizationRuleId": {
                                "value": "[parameters('eventHubAuthorizationRuleId')]"
                            },
                            "eventHubName": {
                                "value": "[parameters('eventHubName')]"
                            },
                            "resourceLocation": {
                                "value": "[field('location')]"
                            },
                            "resourceName": {
                                "value": "[field('name')]"
                            },
                            "diagnosticSettingName": {
                                "value": "[parameters('diagnosticSettingName')]"
                            },
                            "metricsEnabled": {
                                "value": "[parameters('metricsEnabled')]"
                            },
                            "logsEnabled": {
                                "value": "[parameters('logsEnabled')]"
                            }
                        }
                    }
                }
            }
        }
}
POLICY_RULE


  parameters = <<PARAMETERS
{
    "eventHubAuthorizationRuleId": {
            "type": "String",
            "metadata": {
                "displayName": "Event Hub Authorization Rule Id",
                "description": "The Event Hub authorization rule Id for Azure Diagnostics. The authorization rule needs to be at Event Hub namespace level. e.g. /subscriptions/{subscription Id}/resourceGroups/{resource group}/providers/Microsoft.EventHub/namespaces/{Event Hub namespace}/authorizationrules/{authorization rule}",
                "strongType": "Microsoft.EventHub/Namespaces/AuthorizationRules",
                "assignPermissions": true
            }
        },
        "eventHubName": {
            "type": "String",
            "metadata": {
                "displayName": "Event Hub Name",
                "description": "Specify the name of the Event Hub"
            }
        },
        "effect": {
            "type": "String",
            "metadata": {
                "displayName": "Effect",
                "description": "Enable or disable the execution of the policy"
            },
            "allowedValues": [
                "DeployIfNotExists",
                "AuditIfNotExists",
                "Disabled"
            ],
            "defaultValue": "DeployIfNotExists"
        },
        "diagnosticSettingName": {
            "type": "String",
            "metadata": {
                "displayName": "Profile name",
                "description": "The diagnostic settings profile name"
            },
            "defaultValue": "setbypolicy_EH"
        },
        "metricsEnabled": {
            "type": "String",
            "metadata": {
                "displayName": "Enable metrics",
                "description": "Whether to enable metrics stream to the Event Hub - True or False"
            },
            "allowedValues": [
                "True",
                "False"
            ],
            "defaultValue": "False"
        },
        "logsEnabled": {
            "type": "String",
            "metadata": {
                "displayName": "Enable logs",
                "description": "Whether to enable logs stream to the Event Hub - True or False"
            },
            "allowedValues": [
                "True",
                "False"
            ],
            "defaultValue": "True"
        },
        "resourceLocation": {
            "type": "String",
            "metadata": {
                "displayName": "Event Hub Location",
                "description": "Resource Location must be in the same location as the Event Hub Namespace.",
                "strongType": "location"
            }
        }    
}
PARAMETERS

}

