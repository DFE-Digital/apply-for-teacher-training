const getPath = (endpoint, query) => {
  return `${endpoint}?query=${query}`
}

const request = (endpoint) => {
  let xhr = null // Hoist this call so that we can abort previous requests.

  return (query, callback) => {
    if (xhr && xhr.readyState !== XMLHttpRequest.DONE) {
      xhr.abort()
    }
    const path = getPath(endpoint, query)

    xhr = new XMLHttpRequest()
    xhr.addEventListener('load', () => {
      let results = []
      try {
        results = JSON.parse(xhr.responseText)
      } catch (err) {
        console.error(
          `Failed to parse results from endpoint ${path}, error is:`,
          err
        )
      }
      callback(results)
    })
    xhr.open('GET', path)
    xhr.send()
  }
}

export { getPath, request }
