import { accessibleAutosuggestFromSource } from './helpers'

export const initAutosuggest = ({ inputIds, containerId, templates = {}, styles = () => {}, stripWhitespace = true }) => {
  try {
    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId)
      if (!input) return

      const container = document.getElementById(containerId)
      if (!container) return

      const options = {
        templates: {
          inputValue: templates.inputTemplate,
          suggestion: templates.suggestionTemplate
        }
      }

      if (stripWhitespace) {
        options.source = initAutosuggest.stripWhitespaceFilter(
          JSON.parse(container.dataset.source)
        )
      }

      accessibleAutosuggestFromSource(
        input,
        container,
        options
      )

      styles(containerId)
    })
  } catch (err) {
    console.error(`Could not enhance ${containerId}:`, err)
  }
}

initAutosuggest.stripWhitespaceFilter = (_source) => {
  const source = _source
  return (query, populateResults) => {
    const matches = source.filter(r => r.toLowerCase().indexOf(query.toLowerCase().trim()) !== -1)
    populateResults(matches)
  }
}
