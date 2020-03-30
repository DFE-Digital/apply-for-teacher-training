require.context("govuk-frontend/govuk/assets");
import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initNationalityAutocomplete from "./nationality-autocomplete";
import initCoursesAutocomplete from "./courses-autocomplete";
import initProvidersAutocomplete from "./providers-autocomplete";


import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application.scss";
govUKFrontendInitAll();

initNationalityAutocomplete();
initProvidersAutocomplete();
initCoursesAutocomplete();

if (document.getElementsByClassName("govuk-textarea").length >= 1) {
  console.log("there's a textarea")
  const $form = document.getElementsByTagName("form")[0]
  console.log('show a thing 1')

  if ($form) {
    console.log('show a thing 2')

    $form.addEventListener("submit", function() {
    console.log('show a thing 3')

      window.onbeforeunload = null;
    });
  }
  console.log('show a thing 4')

  window.onbeforeunload = function() {
    console.log('show a thing 5')
    return "";
  };
}
