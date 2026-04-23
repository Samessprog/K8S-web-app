{{- define "frontend.fullname" -}}
{{- .Release.Name }}-frontend
{{- end }}

{{- define "frontend.labels" }}
app.kubernetes.io/name: frontend
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}