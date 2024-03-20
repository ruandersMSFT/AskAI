module "ApplicationInsights" {
  source = "./_modules/ApplicationInsights"

  name                = local.application_insights_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
  sampling_percentage = 0
  workspace_id        = module.LogAnalyticsWorkspace.id

  tags = local.tags
}

resource "azurerm_monitor_action_group" "example" {
  name                = "Application Insights Smart Detection"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "SmartDetect"

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }

  tags = local.tags
}

resource "azurerm_monitor_smart_detector_alert_rule" "example" {
  name                = "Failure Anomalies - ${local.application_insights_name}"
  resource_group_name = azurerm_resource_group.example.name
  severity            = "Sev3"
  scope_resource_ids  = [module.ApplicationInsights.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
  description         = "Detects if your application experiences an abnormal rise in the rate of HTTP requests or dependency calls that are reported as failed. The anomaly detection uses machine learning algorithms and occurs in near real time, therefore there's no need to define a frequency for this signal.<br><br>To help you triage and diagnose the problem, an analysis of the characteristics of the failures and related telemetry is provided with the detection. This feature works for any app, hosted in the cloud or on your own servers, that generates request or dependency telemetry - for example, if you have a worker role that calls <a class=\"ext-smartDetecor-link\" href=\\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackrequest\\\" target=\\\"_blank\\\">TrackRequest()</a> or <a class=\"ext-smartDetecor-link\" href=\\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackdependency\\\" target=\\\"_blank\\\">TrackDependency()</a>.<br/><br/><a class=\"ext-smartDetecor-link\" href=\\\"https://docs.microsoft.com/azure/azure-monitor/app/proactive-failure-diagnostics\\\" target=\\\"_blank\\\">Learn more about Failure Anomalies</a><br><br><p style=\\\"font-size: 13px; font-weight: 700;\\\">A note about your data privacy:</p><br><br>The service is entirely automatic and only you can see these notifications. <a class=\\\"ext-smartDetecor-link\\\" href=\\\"https://docs.microsoft.com/en-us/azure/azure-monitor/app/data-retention-privacy\\\" target=\\\"_blank\\\">Read more about data privacy</a><br><br>Smart Alerts conditions can't be edited or added for now."

  action_group {
    ids = [azurerm_monitor_action_group.example.id]
  }

  tags = local.tags
}
