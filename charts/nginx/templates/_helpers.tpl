{{- define "nginx.fullname" -}}
{{- .Release.Name }}-nginx
{{- end }}

{{- define "nginx.labels" -}}
app.kubernetes.io/name: nginx
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}