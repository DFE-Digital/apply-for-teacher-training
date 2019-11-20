require.context("govuk-frontend/govuk/assets");
import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import Rails from "@rails/ujs";
import initNationalityAutocomplete from "./nationality-autocomplete";

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application.scss";
govUKFrontendInitAll();
Rails.start();

initNationalityAutocomplete();
