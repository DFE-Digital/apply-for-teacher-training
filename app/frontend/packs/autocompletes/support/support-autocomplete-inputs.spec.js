import {supportAutocompleteInputs} from "./support-autocomplete-inputs";

describe("supportAutocompleteInputs", () => {
  it("should return supportAutocompleteInputs", () => {
    expect(supportAutocompleteInputs).toMatchSnapshot();
  });
});
