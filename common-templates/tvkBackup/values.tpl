backupTargets:
  &target backblaze-palebluedot:
    type: ObjectStore
    vendor: Other
    objectStoreCredentials:
      url: https://s3.us-west-000.backblazeb2.com
      bucketName: palebluedot-tvk
      region: us-west-000
      credentialSecret:
        name: *target
    thresholdCapacity: 25Gi

backupPlan:
  dev-ffk:
    backupTarget: *target
    backupPlanFlags:
      skipImageBackup: true
    policies:
      retention-policy:
        type: Retention
        spec:
          cleanupConfig:
            backupDays: 2
          default: false
          retentionConfig:
            dayOfWeek: Sunday
            weekly: 1
            latest: 3
      fullbackup-policy:
        type: Schedule
        spec:
          default: false
          scheduleConfig:
            schedule:
            - 10 4 * 1/3 *
      incremental-policy:
        type: Schedule
        spec:
          default: false
          scheduleConfig:
            schedule:
            - 15 4 * * *
    excludeResources:
      labelSelector:
      - matchExpressions:
        - key: tvk-skip-object
          operator: In
          values:
          - "true"

infisicalSecret:
  *target:
    syncInterval: 900
    secretsPath: global