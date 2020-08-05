require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initNationalityAutocomplete from "./nationality-autocomplete";
import initCoursesAutocomplete from "./courses-autocomplete";
import initCountryAutocomplete from "./country-autocomplete";
import initProvidersAutocomplete from "./providers-autocomplete";
import initDegreeGradeAutocomplete from "./degree-grade-autocomplete";
import initDegreeInstitutionAutocomplete from "./degree-institution-autocomplete";
import initDegreeInstitutionCountryAutocomplete from "./degree-institution-country-autocomplete";
import initDegreeSubjectAutocomplete from "./degree-subject-autocomplete";
import initDegreeTypeAutocomplete from "./degree-type-autocomplete";
import initGcseGradeAutocomplete from "./gcse-grade-autocomplete";
import initIeltsBandScoreAutocomplete from "./ielts-band-score-autocomplete";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import providerFilter from "./provider-filter";
import nationalitiesComponent from "./nationalities-component";

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application.scss";
govUKFrontendInitAll();

initNationalityAutocomplete();
initProvidersAutocomplete();
initCoursesAutocomplete();
initCountryAutocomplete();
initDegreeGradeAutocomplete();
initDegreeInstitutionAutocomplete();
initDegreeInstitutionCountryAutocomplete();
initDegreeSubjectAutocomplete();
initDegreeTypeAutocomplete();
initGcseGradeAutocomplete();
initIeltsBandScoreAutocomplete();
initWarnOnUnsavedChanges();
providerFilter();
nationalitiesComponent();
