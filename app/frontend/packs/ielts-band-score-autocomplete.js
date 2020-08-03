import accessibleAutocomplete from "accessible-autocomplete";

const initIeltsBandScoreAutocomplete = () => {
  try {
    const ids = [
      "#candidate-interface-english-foreign-language-ielts-form-band-score-field",
      "#candidate-interface-english-foreign-language-ielts-form-band-score-field-error",
    ]

    ids.forEach(id => {
      const bandScoreSelect = document.querySelector(id);

      if (!bandScoreSelect) return;

      accessibleAutocomplete.enhanceSelectElement({
        defaultValue: '',
        selectElement: bandScoreSelect,
        showAllValues: true,
        showNoOptionsFound: true,
        confirmOnBlur: false
      });
    });
  } catch (err) {
    console.error("Could not enhance IELTS score select:", err);
  }
};

export default initIeltsBandScoreAutocomplete;
