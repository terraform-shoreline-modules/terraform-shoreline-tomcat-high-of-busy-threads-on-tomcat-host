resource "shoreline_notebook" "high_of_busy_threads_on_tomcat_host_test" {
  name       = "high_of_busy_threads_on_tomcat_host_test"
  data       = file("${path.module}/data/high_of_busy_threads_on_tomcat_host_test.json")
  depends_on = [shoreline_action.invoke_get_thread_dump,shoreline_action.invoke_cpu_usage_check,shoreline_action.invoke_thread_analysis,shoreline_action.invoke_tomcat_config_check]
}

resource "shoreline_file" "get_thread_dump" {
  name             = "get_thread_dump"
  input_file       = "${path.module}/data/get_thread_dump.sh"
  md5              = filemd5("${path.module}/data/get_thread_dump.sh")
  description      = "Improper configuration of the Tomcat server leading to inefficient use of threads and high utilization of the available threads."
  destination_path = "/agent/scripts/get_thread_dump.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cpu_usage_check" {
  name             = "cpu_usage_check"
  input_file       = "${path.module}/data/cpu_usage_check.sh"
  md5              = filemd5("${path.module}/data/cpu_usage_check.sh")
  description      = "Bugs or defects in the application running on the Tomcat server leading to high thread usage."
  destination_path = "/agent/scripts/cpu_usage_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "thread_analysis" {
  name             = "thread_analysis"
  input_file       = "${path.module}/data/thread_analysis.sh"
  md5              = filemd5("${path.module}/data/thread_analysis.sh")
  description      = "Identify and resolve any bottlenecks in the application code that may be causing excessive thread usage."
  destination_path = "/agent/scripts/thread_analysis.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "tomcat_config_check" {
  name             = "tomcat_config_check"
  input_file       = "${path.module}/data/tomcat_config_check.sh"
  md5              = filemd5("${path.module}/data/tomcat_config_check.sh")
  description      = "Check the configuration of the Tomcat server to ensure that it is optimized for the expected traffic volume."
  destination_path = "/agent/scripts/tomcat_config_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_thread_dump" {
  name        = "invoke_get_thread_dump"
  description = "Improper configuration of the Tomcat server leading to inefficient use of threads and high utilization of the available threads."
  command     = "`chmod +x /agent/scripts/get_thread_dump.sh && /agent/scripts/get_thread_dump.sh`"
  params      = ["LOCATION_OF_THREAD_DUMP_FILE","PATH_TO_JAVA_HOME","NAME_OF_TOMCAT_CONTAINER","NAME_OF_THREAD_DUMP_FILE","NAME_OF_TOMCAT_POD"]
  file_deps   = ["get_thread_dump"]
  enabled     = true
  depends_on  = [shoreline_file.get_thread_dump]
}

resource "shoreline_action" "invoke_cpu_usage_check" {
  name        = "invoke_cpu_usage_check"
  description = "Bugs or defects in the application running on the Tomcat server leading to high thread usage."
  command     = "`chmod +x /agent/scripts/cpu_usage_check.sh && /agent/scripts/cpu_usage_check.sh`"
  params      = ["DEPLOYMENT_NAME","NAMESPACE","NAME_OF_TOMCAT_CONTAINER"]
  file_deps   = ["cpu_usage_check"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_usage_check]
}

resource "shoreline_action" "invoke_thread_analysis" {
  name        = "invoke_thread_analysis"
  description = "Identify and resolve any bottlenecks in the application code that may be causing excessive thread usage."
  command     = "`chmod +x /agent/scripts/thread_analysis.sh && /agent/scripts/thread_analysis.sh`"
  params      = ["LOG_FILE_NAME","NAMESPACE","NAME_OF_TOMCAT_CONTAINER","NAME_OF_TOMCAT_POD"]
  file_deps   = ["thread_analysis"]
  enabled     = true
  depends_on  = [shoreline_file.thread_analysis]
}

resource "shoreline_action" "invoke_tomcat_config_check" {
  name        = "invoke_tomcat_config_check"
  description = "Check the configuration of the Tomcat server to ensure that it is optimized for the expected traffic volume."
  command     = "`chmod +x /agent/scripts/tomcat_config_check.sh && /agent/scripts/tomcat_config_check.sh`"
  params      = ["TOMCAT_CONFIG_FILE","NAMESPACE","POD_LABEL","NAME_OF_TOMCAT_CONTAINER"]
  file_deps   = ["tomcat_config_check"]
  enabled     = true
  depends_on  = [shoreline_file.tomcat_config_check]
}

