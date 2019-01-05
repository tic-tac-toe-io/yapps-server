const opts =
  web:
    port: 3000
    upload_storage: \memory

  logger:
    rotating_file_stream:
      period: \daily
      threshold: \1g    # The maximum size for a log file to reach before it's rotated.
      totalFiles: 60    # Keep 60 days (2 months) of log files.

console.log "opts => #{JSON.stringify opts}"
module.exports = exports = opts