import accessibleAutocomplete from "accessible-autocomplete";

const initIeltsBandScoreAutocomplete = () => {
  try {
    const ids = [
      "#candidate-interface-english-foreign-language-ielts-form-band-score-field",
      "#candidate-interface-english-foreign-language-ielts-form-band-score-field-error",
    ]

    ids.forEach(id => {
      const selectElement = document.querySelector(id);
      if (!selectElement) return;

      accessibleAutocomplete.enhanceSelectElement({
        selectElement,
        autoselect: false,
        confirmOnBlur: false,
        defaultValue: "",
        showAllValues: true,
        showNoOptionsFound: true
      });

      const accessibleAutocompleteWrapper = document.querySelector(".govuk-form-group--ielts-band-score .autocomplete__wrapper");
      accessibleAutocompleteWrapper.classList.add("govuk-input--width-5");
    });
  } catch (err) {
    console.error("Could not enhance IELTS score select:", err);
  }
};

export default initIeltsBandScoreAutocomplete;
