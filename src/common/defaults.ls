
#
# Predefined variables for configuration file:
#
#   - app_name
#   - process_name => m0, w0, w1, w2, w3...
#   - current_dir
#   - work_dir
#   - logs_dir
#   - startup_time
#


const opts =
  web:
    port: 3000
    api: 3
    upload_storage: \memory
    upload_path: "{{work_dir}}/web/upload/{{wid}}"

  logger:
    rotating_file_stream:
      period: \daily
      threshold: \1g    # The maximum size for a log file to reach before it's rotated.
      totalFiles: 60    # Keep 60 days (2 months) of log files.

console.log "opts => #{JSON.stringify opts}"
module.exports = exports = opts