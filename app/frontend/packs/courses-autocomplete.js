import accessibleAutocomplete from "accessible-autocomplete";

const initCoursesAutocomplete = () => {
  try {
    const id = "#pick-course-form .govuk-select";
    const selectElement = document.querySelector(id);
    if (!selectElement) return;

    // Replace "Select a course" with empty string
    selectElement.querySelector("[value='']").innerHTML = "";

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showAllValues: true
    });
  } catch (err) {
    console.error("Could not enhance courses select:", err);
  }
};

export default initCoursesAutocomplete;
