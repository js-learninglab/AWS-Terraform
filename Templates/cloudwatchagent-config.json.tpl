{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "nginx_access_logs-dev",
            "log_stream_name": "{instance_id}-nginx-access"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "nginx_error_logs-dev",
            "log_stream_name": "{instance_id}-nginx-error"
          }
        ]
      }
    }
  }
}