const nationalitiesComponent = () => {
  const nationalitySelects = [
    "candidate-interface-nationalities-form-other-nationality1-field",
    "candidate-interface-nationalities-form-other-nationality1-field-error",
    "candidate-interface-nationalities-form-other-nationality2-field",
    "candidate-interface-nationalities-form-other-nationality2-field-error",
    "candidate-interface-nationalities-form-other-nationality3-field",
    "candidate-interface-nationalities-form-other-nationality3-field-error",
  ];

  const firstNationalitySelect = [
    "candidate-interface-nationalities-form-other-nationality1-field",
    "candidate-interface-nationalities-form-other-nationality1-field-error",
  ];


  const thirdNationalitySelect = [
    "candidate-interface-nationalities-form-other-nationality3-field",
    "candidate-interface-nationalities-form-other-nationality3-field-error",
  ];

  const errorSelects = [
    "candidate-interface-nationalities-form-other-nationality1-field-error",
    "candidate-interface-nationalities-form-other-nationality2-field-error",
    "candidate-interface-nationalities-form-other-nationality3-field-error",
  ];


  nationalitySelects.forEach(id => {
    var selectNationality = document.getElementById(id);

    if (selectNationality) {
      var form = selectNationality.parentElement.parentElement;
      addRemoveNationalityLink(form)
      addNationalityButton(selectNationality, id)

      // hide the form group if the select has no value or does not have an error. The first div always shows
      if (notOtherNationality1(id) && selectNationality.value === "" && !errorSelects.includes(id)) {
        form.parentElement.style.display = 'none';
      }
    }
  })

  function addRemoveNationalityLink(form) {
    var removeNationalityLink = document.createElement("a");
    removeNationalityLink.innerHTML = "Remove";
    removeNationalityLink.classList.add('govuk-link');
    form.before(removeNationalityLink);

    // removeNationalityLink.addEventListener ("click", removeNationality(selectNationality));
  }

  function addNationalityButton(selectNationality, id) {
    if (!thirdNationalitySelect.includes(id)) {
      var button = document.createElement("a");
      button.innerHTML = "Add another nationality";
      button.classList.add('govuk-button', 'govuk-button--secondary', 'govuk-!-margin-top-5', 'govuk-!-margin-bottom-2');
      selectNationality.after(button);

      // the button shows if there is no value on the next select, with the exception of if there is an error as the section is already rendered
      var secondError = document.getElementById("candidate-interface-nationalities-form-other-nationality2-field-error")
      var thirdError = document.getElementById("candidate-interface-nationalities-form-other-nationality3-field-error")

      if (!notOtherNationality1(id) && (getSecondSelect().value !== "" || secondError)) {
        button.style.display = 'none';
      }
      else if (getThirdSelect().value !== "" || thirdError) {
        button.style.display = 'none';
      }


      button.addEventListener("click", function() { addNationalityEvent(id, button); });
    }
  }

  function notOtherNationality1(id) {
    if (firstNationalitySelect.includes(id)) {
      return false;
    }
    else
    {
      return true;
    }
  }

  function getSecondSelect() {
    var select = document.getElementById("candidate-interface-nationalities-form-other-nationality2-field");
    if(!select) {
      select = document.getElementById("candidate-interface-nationalities-form-other-nationality2-field-error");
    }

    return select;
  }

  function getThirdSelect() {
    var select = document.getElementById("candidate-interface-nationalities-form-other-nationality3-field");
    if(!select) {
      select = document.getElementById("candidate-interface-nationalities-form-other-nationality3-field-error");
    }

    return select;
  }

  function addNationalityEvent(id, addNationalityButton) {
    if (!notOtherNationality1(id)) {
      var secondSelect = getSecondSelect();
      secondSelect.parentElement.parentElement.parentElement.style.display = 'block';
    }
    else
    {
      var thirdSelect = getThirdSelect();
      thirdSelect.parentElement.parentElement.parentElement.style.display = 'block';
    }

    addNationalityButton.style.display = 'none';
  }

  // function removeNationality(selectNationality) {
  //
  // }
};

export default nationalitiesComponent;
