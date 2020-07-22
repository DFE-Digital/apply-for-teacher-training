import accessibleAutocomplete from "accessible-autocomplete";

const initIeltsBandScoreAutocomplete = () => {
  try {
    const id = "#candidate-interface-english-foreign-language-ielts-form-band-score-field";
    const bandScoreSelect = document.querySelector(id);

    if (!bandScoreSelect) return;

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: bandScoreSelect,
      showAllValues: true,
      confirmOnBlur: false
    });
  } catch (err) {
    console.error("Could not enhance IELTS score select:", err);
  }
};

export default initIeltsBandScoreAutocomplete;
