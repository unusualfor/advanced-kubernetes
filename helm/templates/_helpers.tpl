{{- define "simple-nginx.name" -}}
simple-nginx
{{- end -}}

{{- define "simple-nginx.fullname" -}}
{{ include "simple-nginx.name" . }}
{{- end -}}
