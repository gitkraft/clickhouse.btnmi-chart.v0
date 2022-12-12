{{/*
Return the proper ClickHouse image name
*/}}
{{- define "clickhouse.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "clickhouse.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "clickhouse.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "clickhouse.createTlsSecret" -}}
{{- if and .Values.tls.autoGenerated (not .Values.tls.certificatesSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "clickhouse.tlsSecretName" -}}
{{- if .Values.tls.autoGenerated }}
    {{- printf "%s-crt" (include "common.names.fullname" .) -}}
{{- else -}}
    {{ required "A secret containing TLS certificates is required when TLS is enabled" .Values.tls.certificatesSecret }}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert file.
*/}}
{{- define "clickhouse.tlsCert" -}}
{{- if .Values.tls.autoGenerated }}
    {{- printf "/opt/bitnami/clickhouse/certs/tls.crt" -}}
{{- else -}}
    {{- required "Certificate filename is required when TLS in enabled" .Values.tls.certFilename | printf "/opt/bitnami/clickhouse/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert key file.
*/}}
{{- define "clickhouse.tlsCertKey" -}}
{{- if .Values.tls.autoGenerated }}
    {{- printf "/opt/bitnami/clickhouse/certs/tls.key" -}}
{{- else -}}
{{- required "Certificate Key filename is required when TLS in enabled" .Values.tls.certKeyFilename | printf "/opt/bitnami/clickhouse/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "clickhouse.tlsCACert" -}}
{{- if .Values.tls.autoGenerated }}
    {{- printf "/opt/bitnami/clickhouse/certs/ca.crt" -}}
{{- else -}}
    {{- printf "/opt/bitnami/clickhouse/certs/%s" .Values.tls.certCAFilename -}}
{{- end -}}
{{- end -}}

{{/*
Get the ClickHouse configuration configmap.
*/}}
{{- define "clickhouse.configmapName" -}}
{{- if .Values.existingOverridesConfigmap -}}
    {{- .Values.existingOverridesConfigmap -}}
{{- else }}
    {{- printf "%s" (include "common.names.fullname" . ) -}}
{{- end -}}
{{- end -}}

{{/*
Get the ClickHouse configuration configmap.
*/}}
{{- define "clickhouse.extraConfigmapName" -}}
{{- if .Values.extraOverridesConfigmap -}}
    {{- .Values.extraOverridesConfigmap -}}
{{- else }}
    {{- printf "%s-extra" (include "common.names.fullname" . ) -}}
{{- end -}}
{{- end -}}

{{/*
Get the Clickhouse password secret name
*/}}
{{- define "clickhouse.secretName" -}}
{{- if .Values.auth.existingSecret -}}
    {{- .Values.auth.existingSecret -}}
{{- else }}
    {{- printf "%s" (include "common.names.fullname" . ) -}}
{{- end -}}
{{- end -}}

{{/*
Get the ClickHouse password key inside the secret
*/}}
{{- define "clickhouse.secretKey" -}}
{{- if .Values.auth.existingSecret -}}
    {{- .Values.auth.existingSecretKey -}}
{{- else }}
    {{- print "admin-password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the startialization scripts Secret name.
*/}}
{{- define "clickhouse.startdbScriptsSecret" -}}
{{- if .Values.startdbScriptsSecret -}}
    {{- printf "%s" (tpl .Values.startdbScriptsSecret $) -}}
{{- else -}}
    {{- printf "%s-start-scripts" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the initialization scripts Secret name.
*/}}
{{- define "clickhouse.initdbScriptsSecret" -}}
{{- if .Values.initdbScriptsSecret -}}
    {{- printf "%s" (tpl .Values.initdbScriptsSecret $) -}}
{{- else -}}
    {{- printf "%s-init-scripts" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "clickhouse.headlessServiceName" -}}
{{-  printf "%s-headless" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "clickhouse.zookeeper.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "zookeeper" "chartValues" .Values.zookeeper "context" $) -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "clickhouse.zookeeper.headlessServiceName" -}}
{{-  printf "%s-headless" (include "clickhouse.zookeeper.fullname" .) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "clickhouse.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "clickhouse.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "clickhouse.validateValues.zookeeper" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/* Validate values of ClickHouse - [Zoo]keeper */}}
{{- define "clickhouse.validateValues.zookeeper" -}}
{{- if or (and .Values.keeper.enabled .Values.zookeeper.enabled) (and .Values.keeper.enabled .Values.externalZookeeper.servers) (and .Values.zookeeper.enabled .Values.externalZookeeper.servers) -}}
clickhouse: Multiple [Zoo]keeper
    You can only use one [zoo]keeper
    Please choose use ClickHouse keeper or 
    installing a Zookeeper chart (--set zookeeper.enabled=true) or
    using an external instance (--set zookeeper.servers )
{{- end -}}
{{- if and (not .Values.keeper.enabled) (not .Values.zookeeper.enabled) (not .Values.externalZookeeper.servers) (ne (int .Values.shards) 1) (ne (int .Values.replicaCount) 1) -}}
clickhouse: No [Zoo]keeper
    If you are deploying more than one ClickHouse instance, you need to enable [Zoo]keeper. Please choose installing a [Zoo]keeper (--set keeper.enabled=true) or (--set zookeeper.enabled=true) or
    using an external instance (--set zookeeper.servers )
{{- end -}}
{{- end -}}
