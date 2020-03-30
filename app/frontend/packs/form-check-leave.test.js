import FormCheckLeave from "./form-check-leave";

describe("FormCheckLeave", () => {
  it("something", () => {
    const form = {
      addEventListener: jest.fn()
    };

    const formCheckLeave = new FormCheckLeave(form);

    formCheckLeave.init();

    expect(form.addEventListener).toHaveBeenCalledWith(
      "submit",
      expect.anything()
    );
    expect(form.addEventListener).toHaveBeenCalledWith(
      "change",
      expect.anything()
    );
    expect(window.onbeforeunload).toBeInstanceOf(Function);
    expect(window.onbeforeunload()).toEqual(undefined);
    form.addEventListener.mock.calls[1][1]();
    const event = { preventDefault: jest.fn() };
    expect(window.onbeforeunload(event)).toEqual(
      "You have unsaved changes, are you sure you want to leave?"
    );
    expect(event.preventDefault).toHaveBeenCalled();
  });

  it("prevents leaving if the form has been changed", () => {});

  it("allows leaving if the form has not been changed", () => {});

  it("allows submitting", () => {});
});
