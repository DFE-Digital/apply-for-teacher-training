import {
  degreeGradeAutosuggestInputs,
  degreeInstitutionAutosuggestInputs,
  degreeSubjectAutosuggestInputs,
  degreeTypeAutosuggestInputs,
  otherQualificationsGradeAutosuggestInputs,
  otherQualificationsSubjectAutosuggestInputs, otherQualificationsTypeAutosuggestInputs
} from "./autosuggest-inputs";

describe("autosuggestInputs", () => {
  it("should return degreeGradeAutosuggestInputs", () => {
    expect(degreeGradeAutosuggestInputs).toMatchSnapshot();
  });

  it("should return degreeGradeAutosuggestInputs", () => {
    expect(degreeInstitutionAutosuggestInputs).toMatchSnapshot();
  });

  it("should return degreeSubjectAutosuggestInputs", () => {
    expect(degreeSubjectAutosuggestInputs).toMatchSnapshot();
  });

  it("should return degreeTypeAutosuggestInputs", () => {
    expect(degreeTypeAutosuggestInputs).toMatchSnapshot();
  });

  it("should return otherQualificationsSubjectAutosuggestInputs", () => {
    expect(otherQualificationsSubjectAutosuggestInputs).toMatchSnapshot();
  });

  it("should return otherQualificationsGradeAutosuggestInputs", () => {
    expect(otherQualificationsGradeAutosuggestInputs).toMatchSnapshot();
  });

  it("should return otherQualificationsTypeAutosuggestInputs", () => {
    expect(otherQualificationsTypeAutosuggestInputs).toMatchSnapshot();
  });
});
