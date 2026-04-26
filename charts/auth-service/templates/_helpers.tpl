{{- define "auth-service.fullname" -}}
{{- .Release.Name }}-auth-service
{{- end }}

{{- define "auth-service.labels" }}
app.kubernetes.io/name: auth-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
