const nationalitiesComponent = () => {

  const pageHasErrors = document.querySelector('.govuk-error-summary');
  if (pageHasErrors) return;

  const secondSelect = document.getElementById(
    "candidate-interface-nationalities-form-other-nationality2-field"
  );

  const thirdSelect = document.getElementById(
    "candidate-interface-nationalities-form-other-nationality3-field"
  );

  const secondFormLabel = document.querySelector(
    "[for=candidate-interface-nationalities-form-other-nationality2-field]"
  );
  const thirdFormLabel = document.querySelector(
    "[for=candidate-interface-nationalities-form-other-nationality3-field]"
  );

  addRemoveLink(
    secondSelect.id
  );

  addRemoveLink(
    thirdSelect.id
  );

  addAddNationalityButton(
    "#candidate-interface-nationalities-form-other-other-conditional"
  );

  hideSection(
    secondSelect.id
  );

  hideSection(
    thirdSelect.id
  );

  function addRemoveLink(selector) {
    const labelEl = document.querySelector(`[for=${selector}]`);
    const removeLink = document.createElement("a");
    removeLink.innerHTML = "Remove";
    removeLink.classList.add("govuk-link", "app-nationality-remove-link");

    // This has to be a link and not a button as the govuk-link class requires an
    // href to apply  it's styling
    removeLink.href = "#";
    labelEl.appendChild(removeLink);

    removeLink.addEventListener("click", function () {
      handleRemoveLinkClick(labelEl, selector);
    });
  }

  function addAddNationalityButton(parentSelector) {
    const parent = document.querySelector(parentSelector);
    const nationalityButton = document.createElement("button");
    nationalityButton.innerHTML = "Add another nationality";
    nationalityButton.id = "add-nationality-button";
    nationalityButton.classList.add("govuk-button", "govuk-button--secondary");
    parent.appendChild(nationalityButton);

    if (secondSelect.value && thirdSelect.value) {
      nationalityButton.style.display = "none";
    }

    nationalityButton.addEventListener("click", function () {
      event.preventDefault();
      handleAddNationalityClick(nationalityButton);
    });
  }

  function hideSection(selector) {
    const select = document.getElementById(selector);
    const labelEl = document.querySelector(`[for=${selector}]`);

    if (select.value === "") {
      labelEl.parentElement.style.display = "none";
    }
  }

  function handleRemoveLinkClick(labelEl, selector) {
    const addNationalityButton = document.getElementById(
      "add-nationality-button"
    );

    addNationalityButton.style.display = "";
    labelEl.parentElement.style.display = "none";
    document.getElementById(selector).value = "";
  }

  function handleAddNationalityClick(nationalityButton) {

    if (
      secondFormLabel.parentElement.style.display === "none" &&
      thirdFormLabel.parentElement.style.display === "none"
    ) {
      secondFormLabel.parentElement.style.display = "";
    }
    else if (secondFormLabel.parentElement.style.display === "none") {
      secondFormLabel.parentElement.style.display = "";
      nationalityButton.style.display = "none";
    } else {
      thirdFormLabel.parentElement.style.display = "";
      nationalityButton.style.display = "none";
    }
  }
};

export default nationalitiesComponent;
