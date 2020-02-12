describe("Candidate", () => {
  before(() => {
    cy.clearCookie("_apply_for_postgraduate_teacher_training_session");
    Cypress.Cookies.defaults({
      whitelist: "_apply_for_postgraduate_teacher_training_session"
    });
  });

  it("can load the home page", () => {
    cy.visit("https://qa.apply-for-teacher-training.education.gov.uk/");
    cy.contains("Start now");
  });

  it("can check for eligibility", () => {
    cy.contains("Start now").click();
    cy.contains("Check we’re ready for you to use this service");
  });

  it("can reach sign up page", () => {
    cy.get(
      "#candidate-interface-eligibility-form-eligible-citizen-yes-field"
    ).click();
    cy.get(
      "#candidate-interface-eligibility-form-eligible-qualifications-yes-field"
    ).click();

    cy.contains("Continue").click();
    cy.contains("Create an Apply for teacher training account");
  });

  let inbox = null;

  it("can submit their email", () => {
    cy.newEmailAddress().then(newInbox => {
      inbox = newInbox;
      cy.get("#candidate-interface-sign-up-form-email-address-field").type(
        inbox.emailAddress
      );

      cy.get(
        "#candidate-interface-sign-up-form-accept-ts-and-cs-true-field"
      ).click();

      cy.contains("Continue").click();
      cy.contains("Check your email");
    });
  });

  let token = null;

  it("can sign up via magic link", () => {
    cy.getLatestEmail(inbox).then(email => {
      const token = /token=([\d\w]{20})/.exec(email.body)[1];
      expect(token).to.be.ok;

      cy.visit(
        `https://qa.apply-for-teacher-training.education.gov.uk/candidate/authenticate?token=${token}`
      );
      cy.contains("Your application");
    });
  });
});
