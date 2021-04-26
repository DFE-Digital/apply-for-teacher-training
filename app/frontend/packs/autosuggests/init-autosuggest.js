import { accessibleAutosuggestFromSource } from './helpers'

export const initAutosuggest = ({ inputIds, containerId, templates = {}, styles = () => {} }) => {
  try {
    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId)
      if (!input) return

      const container = document.getElementById(containerId)
      if (!container) return

      accessibleAutosuggestFromSource(
        input,
        container,
        {
          templates: {
            inputValue: templates.inputTemplate,
            suggestion: templates.suggestionTemplate
          },
          source: (query, populateResults) => {
            const source = JSON.parse(container.dataset.source)
            const matches = source.filter(r => r.toLowerCase().indexOf(query.toLowerCase().trim()) !== -1)
            populateResults(matches);
          },
        }
      )

      styles(containerId)
    })
  } catch (err) {
    console.error(`Could not enhance ${containerId}:`, err)
  }
}
