; inherits: jinja

; Host language for Perfetto TraceConfig templates (*.pbtxt.j2 / *.pbtx.j2)
((content) @injection.content
  (#set! injection.language "textproto")
  (#set! injection.combined))
