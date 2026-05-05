{{- define "report-service.fullname" -}}
{{- .Release.Name }}-report-service
{{- end }}

{{- define "report-service.labels" }}
app.kubernetes.io/name: report-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
