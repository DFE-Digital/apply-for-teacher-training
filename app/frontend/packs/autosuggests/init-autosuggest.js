import { accessibleAutosuggestFromSource } from './helpers'

export const initAutosuggest = ({ inputIds, containerId, templates = {}, styles = () => {}, stripWhitespace = true }) => {
  try {
    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId)
      if (!input) return

      const container = document.getElementById(containerId)
      if (!container) return

      let options = {
        templates: {
          inputValue: templates.inputTemplate,
          suggestion: templates.suggestionTemplate
        },
      };

      if (stripWhitespace) {
        const source = JSON.parse(container.dataset.source)
        options.source = (query, populateResults) => {
          const matches = source.filter(r => r.toLowerCase().indexOf(query.toLowerCase().trim()) !== -1)
          populateResults(matches)
        }
      }

      accessibleAutosuggestFromSource(
        input,
        container,
        options,
      )

      styles(containerId)
    })
  } catch (err) {
    console.error(`Could not enhance ${containerId}:`, err)
  }
}
