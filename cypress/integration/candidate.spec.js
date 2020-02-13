describe("Candidate", () => {
  let inbox = null;

  it("can sign up successfully", async () => {
    givenIAmOnTheHomePage();
    whenIClickOnStartNow();
    thenICanCheckMyEligibility();

    whenICheckThatIAmEligible();
    andIClickContinue();
    thenICanCreateAnAccount();

    whenITypeInMyEmail();
    andAgreeToTermsAndConditions();
    andIClickContinue();
    thenIAmToldToCheckMyEmail();

    whenIClickTheLinkInMyEmail();
    thenIShouldBeOnTheApplicationPage();
  });

  function givenIAmOnTheHomePage() {
    cy.visit("https://qa.apply-for-teacher-training.education.gov.uk/");
    cy.contains("Start now");
  }

  function whenIClickOnStartNow() {
    cy.contains("Start now").click();
  }

  function thenICanCheckMyEligibility() {
    cy.contains("Check we’re ready for you to use this service");
  }

  function whenICheckThatIAmEligible() {
    cy.get(
      "#candidate-interface-eligibility-form-eligible-citizen-yes-field"
    ).click();
    cy.get(
      "#candidate-interface-eligibility-form-eligible-qualifications-yes-field"
    ).click();
  }

  function andIClickContinue() {
    cy.contains("Continue").click();
  }

  function thenICanCreateAnAccount() {
    cy.contains("Create an Apply for teacher training account");
  }

  function whenITypeInMyEmail() {
    cy.newEmailAddress().then(newInbox => {
      inbox = newInbox;

      cy.get("#candidate-interface-sign-up-form-email-address-field").type(
        inbox.emailAddress
      );
    });
  }

  function andAgreeToTermsAndConditions() {
    cy.get(
      "#candidate-interface-sign-up-form-accept-ts-and-cs-true-field"
    ).click();
  }

  function thenIAmToldToCheckMyEmail() {
    cy.contains("Check your email");
  }

  function whenIClickTheLinkInMyEmail() {
    cy.getLatestEmail(() => inbox.id).then(email => {
      const token = /token=([\d\w]{20})/.exec(email.body)[1];
      expect(token).to.be.ok;

      cy.visit(
        `https://qa.apply-for-teacher-training.education.gov.uk/candidate/authenticate?token=${token}`
      );
    });
  }

  function thenIShouldBeOnTheApplicationPage() {
    cy.contains("Your application");
  }
});
