const getUrl = (endpoint, query) => {
  return `${endpoint}?query=${query}`
}

function request (endpoint) {
  return async (query, callback) => {
    const url = getUrl(endpoint, query)
    try {
      const response = await fetch(url)
      if (!response.ok) {
        throw new Error(`Response status: ${response.status}`)
      }

      const json = await response.json()
      callback(json)
    } catch (error) {
      console.error(error.message)
    }
  }
}

export { getUrl, request }
