import initDegreeGradeAutosuggest from "./degree-grade-autosuggest";

describe("Degree grade autosuggest", () => {
  describe("initDegreeGradeAutoSuggest", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div id="outer-container">
          <label for="candidate-interface-degree-grade-form-other-grade-field">Enter your degree grade</label>
          <div id="degree-grade-autosuggest" data-source='["A","B","C"]' ></div>
        </div>
      `;

      initDegreeGradeAutosuggest();
    });

    it("should instantiate an autocomplete", () => {
      expect(document.querySelector("#outer-container")).toMatchSnapshot();
    });
  })
});

