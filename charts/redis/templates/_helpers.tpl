{{- define "redis.fullname" -}}
{{- .Release.Name }}-redis
{{- end }}

{{- define "redis.labels" }}
app.kubernetes.io/name: redis
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
