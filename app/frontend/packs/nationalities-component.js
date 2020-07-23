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
    "[for=candidate-interface-nationalities-form-other-nationality2-field]"
  );

  addRemoveLink(
    "[for=candidate-interface-nationalities-form-other-nationality3-field]"
  );

  addAddNationalityButton(
    "#candidate-interface-nationalities-form-other-other-conditional"
  );

  hideSection(
    "[id=candidate-interface-nationalities-form-other-nationality2-field]"
  );

  hideSection(
    "[id=candidate-interface-nationalities-form-other-nationality3-field]"
  );

  /*

    if input2 and input3 are empty:
      hide input2 and input3
      actions: add another nationality reveals input2
      if input2 is visible
        actions: add another nationality reveals input3 and hides input2

    if input2 is present, input3 is empty:
      ...

    if input2 is present, input3 is present:
      ...

  */

  function addRemoveLink(selector) {
    const labelEl = document.querySelector(selector);
    const removeLink = document.createElement("a");
    removeLink.innerHTML = "Remove";
    removeLink.classList.add("govuk-link");
    removeLink.href = "#";
    removeLink.style.float = "right"; // FIXME: Put me in CSS!
    labelEl.appendChild(removeLink);
  }

  function addAddNationalityButton(parentSelector) {
    const parent = document.querySelector(parentSelector);
    const nationalityButton = document.createElement("a");
    nationalityButton.innerHTML = "Add another nationality";
    nationalityButton.classList.add(
      "govuk-button",
      "govuk-button--secondary",
    );
    nationalityButton.href = "#";
    parent.appendChild(nationalityButton);

    const secondSelect = document.querySelector("[id=candidate-interface-nationalities-form-other-nationality2-field]")
    const thirdSelect = document.querySelector("[id=candidate-interface-nationalities-form-other-nationality3-field]")

    if(secondSelect.value && thirdSelect.value) {
      nationalityButton.style.display = 'none';
    }

    nationalityButton.addEventListener("click", function () {
      addNationalityEvent();
    })
  }

  function hideSection(selector) {
    const select = document.querySelector(selector)
    if(select.value === "") {
      select.parentElement.parentElement.parentElement.style.display = 'none';
    }
  }

  function addNationalityEvent() {
    const secondFormLabel = document.querySelector("[for=candidate-interface-nationalities-form-other-nationality2-field]");
    const thirdFormLabel = document.querySelector("[for=candidate-interface-nationalities-form-other-nationality3-field]");

    if(secondFormLabel.parentElement.style.display === "none") {
      secondFormLabel.parentElement.style.display = "block";
    }
    else
    {
      thirdFormLabel.parentElement.style.display = "block";
    }
  }


  // function addNationalityButton(selectNationality, id) {
  //     if (
  //       !notOtherNationality1(id) &&
  //       (getSecondSelect().value !== "" || secondError)
  //     ) {
  //       button.style.display = "none";
  //     } else if (getThirdSelect().value !== "" || thirdError) {
  //       button.style.display = "none";
  //     }
  //     button.addEventListener("click", function () {
  //       addNationalityEvent(id, button);
  //     });
  //   }
  // }
  // function notOtherNationality1(id) {
  //   if (firstNationalitySelect.includes(id)) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }
  // function getSecondSelect() {
  //   var select = document.getElementById(
  //     "candidate-interface-nationalities-form-other-nationality2-field"
  //   );
  //   if (!select) {
  //     select = document.getElementById(
  //       "candidate-interface-nationalities-form-other-nationality2-field-error"
  //     );
  //   }
  //   return select;
  // }
  // function getThirdSelect() {
  //   var select = document.getElementById(
  //     "candidate-interface-nationalities-form-other-nationality3-field"
  //   );
  //   if (!select) {
  //     select = document.getElementById(
  //       "candidate-interface-nationalities-form-other-nationality3-field-error"
  //     );
  //   }
  //   return select;
  // }
  // function addNationalityEvent(id, addNationalityButton) {
  //   if (!notOtherNationality1(id)) {
  //     var secondSelect = getSecondSelect();
  //     secondSelect.parentElement.parentElement.parentElement.style.display =
  //       "block";
  //   } else {
  //     var thirdSelect = getThirdSelect();
  //     thirdSelect.parentElement.parentElement.parentElement.style.display =
  //       "block";
  //   }
  //   addNationalityButton.style.display = "none";
  // }
};
export default nationalitiesComponent;
