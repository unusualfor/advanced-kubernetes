{{- define "simple-nginx.name" -}}
{{ .Release.Name }}
{{- end -}}

{{- define "simple-nginx.fullname" -}}
{{ include "simple-nginx.name" . }}
{{- end -}}
