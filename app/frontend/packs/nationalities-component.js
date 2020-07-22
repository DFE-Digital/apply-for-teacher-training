const nationalitiesComponent = () => {
  const inputIds = [
    "#candidate-interface-nationalities-form-other-nationality1-field",
    "#candidate-interface-nationalities-form-other-nationality1-field-error",
  ];

  inputIds.forEach(inputId => {
    const button = document.createElement("button");

    button.innerHTML = "Add nationality";
    button.style.display = "block"

    const select = document.getElementsByTagName(inputId);
    select.appendChild(button);

    button.addEventListener ("click", function() {
      alert("did something");
    });
  });
};

export default nationalitiesComponent;
