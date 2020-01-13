import accessibleAutocomplete from "accessible-autocomplete";

const initCoursesAutocomplete = () => {
  try {
    [
      "#candidate-interface-pick-course-form-code-field",
      "#candidate-interface-pick-course-form-code-field-error"
    ].forEach(id => {
      const coursesSelect = document.querySelector(id);

      if (!coursesSelect) return;

      // Replace "Select a course" with empty string
      coursesSelect.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement: coursesSelect,
        showAllValues: true,
        confirmOnBlur: false
      });
    });
  } catch (err) {
    console.error("Could not enhance courses select:", err);
  }
};

export default initCoursesAutocomplete;
