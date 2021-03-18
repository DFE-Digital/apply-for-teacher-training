import {candidateAutocompleteInputs} from "./candidate-autocomplete-inputs";

describe("candidateAutocompleteInputs", () => {
  it("should return candidateAutocompleteInputs", () => {
    expect(candidateAutocompleteInputs).toMatchSnapshot();
  });
});
