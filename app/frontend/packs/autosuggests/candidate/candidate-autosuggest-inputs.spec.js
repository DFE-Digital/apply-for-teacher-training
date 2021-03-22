import {candidateAutosuggestInputs} from "./candidate-autosuggest-inputs";

describe("candidateAutosuggestInputs", () => {
  it("should return candidateAutosuggestInputs", () => {
    expect(candidateAutosuggestInputs).toMatchSnapshot();
  });
});
