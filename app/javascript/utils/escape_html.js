const HTML_ESCAPE_MAP = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;'
}

const HTML_ESCAPE_PATTERN = /[&<>"']/g

const escapeHTML = (value) => {
  if (value === null || value === undefined) return ''

  const stringValue = String(value)
  return stringValue.replace(HTML_ESCAPE_PATTERN, (match) => HTML_ESCAPE_MAP[match])
}

export { escapeHTML }
