ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command =
  'test ! -f /backups/wal/%f && cp %p /backups/wal/%f';
