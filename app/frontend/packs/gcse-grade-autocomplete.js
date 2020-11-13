import accessibleAutocomplete from "accessible-autocomplete";

const initGcseGradeAutocomplete = () => {
  try {
    const ids = [
      "candidate-interface-gcse-qualification-details-form-grade-field",
      "candidate-interface-gcse-qualification-details-form-grade-field-error",
    ];

    ids.forEach(id => {
      const selectElement = document.getElementById(id);
      if (!selectElement) return;

      accessibleAutocomplete.enhanceSelectElement({
        selectElement,
        autoselect: false,
        confirmOnBlur: false,
        defaultValue: "",
        showAllValues: true,
        showNoOptionsFound: true
      });
    });
  } catch (err) {
    console.error("Could not enhance GCSE grade input:", err);
  }
};

export default initGcseGradeAutocomplete;
