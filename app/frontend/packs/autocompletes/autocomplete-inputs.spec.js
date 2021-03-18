import {autocompleteInputs} from "./autocomplete-inputs";

describe("autocompleteInputs", () => {
  it("should return autocompleteInputs", () => {
    expect(autocompleteInputs).toMatchSnapshot();
  });
});
