import {autosuggestInputs} from "./autosuggest-inputs";

describe("autosuggestInputs", () => {
  it("should return autosuggestInputs", () => {
    expect(autosuggestInputs).toMatchSnapshot();
  });
});
