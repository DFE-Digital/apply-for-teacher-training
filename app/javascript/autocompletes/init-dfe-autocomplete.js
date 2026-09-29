import dfeAutocomplete from 'dfe-autocomplete/src/wrapper'

export const initDfeAutocomplete = () => {
  dfeAutocomplete({ rawAttribute: true, confirmOnBlur: false })
}
