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

  let addNationalityButton = null

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

    addNthNationalityHiddenSpan(removeLink, selector)

    removeLink.addEventListener("click", function () {
      handleRemoveLinkClick(labelEl, selector);
    });
  }

  function addNthNationalityHiddenSpan(removeLink, selector) {
    const nthNationalitySpan = document.createElement("span");
    nthNationalitySpan.classList.add("govuk-visually-hidden")

    if (selector == secondSelect.id) {
      nthNationalitySpan.innerHTML = 'Second nationality';
    }
    else {
      nthNationalitySpan.innerHTML = 'Third nationality';
    }

    removeLink.appendChild(nthNationalitySpan);
  }

  function addAddNationalityButton(parentSelector) {
    const parent = document.querySelector(parentSelector);
    addNationalityButton = document.createElement("button");
    addNationalityButton.innerHTML = "Add another nationality";
    addNationalityButton.id = "add-nationality-button";
    addNationalityButton.classList.add("govuk-button", "govuk-button--secondary");
    parent.appendChild(addNationalityButton);

    if (secondSelect.value && thirdSelect.value) {
      addNationalityButton.style.display = "none";
    }

    addNationalityButton.addEventListener("click", function () {
      event.preventDefault();
      handleAddNationalityClick();
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
    addNationalityButton.style.display = "";
    labelEl.parentElement.style.display = "none";
    document.getElementById(selector).value = "";
  }

  function handleAddNationalityClick() {
    if (
      secondFormLabel.parentElement.style.display === "none" &&
      thirdFormLabel.parentElement.style.display === "none"
    ) {
      secondFormLabel.parentElement.style.display = "";
    }
    else if (secondFormLabel.parentElement.style.display === "none") {
      secondFormLabel.parentElement.style.display = "";
      addNationalityButton.style.display = "none";
    } else {
      thirdFormLabel.parentElement.style.display = "";
      addNationalityButton.style.display = "none";
    }
  }
};

export default nationalitiesComponent;
