{{- define "api-gateway.fullname" -}}
{{- .Release.Name }}-api-gateway
{{- end }}

{{- define "api-gateway.labels" }}
app.kubernetes.io/name: api-gateway
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
