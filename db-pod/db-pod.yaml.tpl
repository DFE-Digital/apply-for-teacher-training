apiVersion: v1
kind: Pod
metadata:
  name: ${DB_TOOLS_POD_NAME}

spec:
  restartPolicy: Never

  securityContext:
    seccompProfile:
      type: RuntimeDefault

  containers:
    - name: postgres-db-tools-pod
      image: ghcr.io/dfe-digital/teacher-services-cloud-db-backup:2911-postgres-backup-via-aks

      envFrom:
        - secretRef:
            name: ${SECRET_REF_NAME}

      env:
        - name: AZURE_STORAGE_SAS_URL
          valueFrom:
            secretKeyRef:
              name: backup-sas
              key: AZURE_STORAGE_SAS_URL

        - name: AZURE_STORAGE_SAS_TOKEN
          valueFrom:
            secretKeyRef:
              name: backup-sas
              key: AZURE_STORAGE_SAS_TOKEN

      command:
        - /bin/bash
        - -c
        - |
          echo "Debug pod started"
          echo "SAS URL loaded: ${AZURE_STORAGE_SAS_URL:+yes}"
          trap : TERM INT
          sleep infinity & wait

      resources:
        requests:
          cpu: "500m"
          memory: "1Gi"

        limits:
          cpu: "1"
          memory: "2Gi"

      securityContext:
        allowPrivilegeEscalation: false

        capabilities:
          drop:
            - ALL
          add:
            - NET_BIND_SERVICE
