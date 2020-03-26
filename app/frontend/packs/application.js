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

  if ($form) {
    $form.addEventListener("submit", function() {
      window.onbeforeunload = null;
    });
  }

  window.onbeforeunload = function() {
    return "";
  };
}
