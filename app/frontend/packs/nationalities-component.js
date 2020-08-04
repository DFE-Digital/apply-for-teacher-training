const nationalitiesComponent = () => {
  if (
    document.querySelector(
      "[for=candidate-interface-nationalities-form-other-nationality2-field-error]"
    ) ||
    document.querySelector(
      "[for=candidate-interface-nationalities-form-other-nationality3-field-error]"
    )
  ) {
    return;
  }

  addRemoveLink(
    "candidate-interface-nationalities-form-other-nationality2-field"
  );

  addRemoveLink(
    "candidate-interface-nationalities-form-other-nationality3-field"
  );

  addAddNationalityButton(
    "#candidate-interface-nationalities-form-other-other-conditional"
  );

  hideSection(
    "candidate-interface-nationalities-form-other-nationality2-field"
  );

  hideSection(
    "candidate-interface-nationalities-form-other-nationality3-field"
  );

  function addRemoveLink(selector) {
    const labelEl = document.querySelector(`[for=${selector}]`);
    const removeLink = document.createElement("a");
    removeLink.innerHTML = "Remove";
    removeLink.classList.add("govuk-link", "remove-link");

    // This has to be a link and not a button as the govuk-link class requires an
    // href to apply  it's styling
    removeLink.href = "#";
    labelEl.appendChild(removeLink);

    removeLink.addEventListener("click", function () {
      addRemoveLinkEvent(labelEl, selector);
    });
  }

  function addAddNationalityButton(parentSelector) {
    const parent = document.querySelector(parentSelector);
    const nationalityButton = document.createElement("button");
    nationalityButton.innerHTML = "Add another nationality";
    nationalityButton.id = "add-nationality-button";
    nationalityButton.classList.add("govuk-button", "govuk-button--secondary");
    parent.appendChild(nationalityButton);

    const secondSelect = document.querySelector(
      "[id=candidate-interface-nationalities-form-other-nationality2-field]"
    );
    const thirdSelect = document.querySelector(
      "[id=candidate-interface-nationalities-form-other-nationality3-field]"
    );

    if (secondSelect.value && thirdSelect.value) {
      nationalityButton.style.display = "none";
    }

    nationalityButton.addEventListener("click", function () {
      event.preventDefault();
      addNationalityEvent(nationalityButton);
    });
  }

  function hideSection(selector) {
    const select = document.getElementById(selector);
    const labelEl = document.querySelector(`[for=${selector}]`);

    if (select.value === "") {
      labelEl.parentElement.style.display = "none";
    }
  }

  function addRemoveLinkEvent(labelEl, selector) {
    const addNationalityButton = document.getElementById(
      "add-nationality-button"
    );

    addNationalityButton.style.display = "";
    labelEl.parentElement.style.display = "none";
    document.getElementById(selector).value = "";
  }

  function addNationalityEvent(nationalityButton) {

    const secondFormLabel = document.querySelector(
      "[for=candidate-interface-nationalities-form-other-nationality2-field]"
    );
    const thirdFormLabel = document.querySelector(
      "[for=candidate-interface-nationalities-form-other-nationality3-field]"
    );


    if (secondFormLabel.parentElement.style.display === "none") {
      secondFormLabel.parentElement.style.display = "";
    } else {
      thirdFormLabel.parentElement.style.display = "";
    }

    if (
      secondFormLabel.parentElement.style.display === "" &&
      thirdFormLabel.parentElement.style.display === ""
    ) {
      nationalityButton.style.display = "none";
    }
  }
};

export default nationalitiesComponent;
