const ENVIRONMENT = Cypress.env("ENVIRONMENT") || "Unknown";
const CANDIDATE_EMAIL = Cypress.env("CANDIDATE_TEST_EMAIL");
// Used in generating a randomish email address like apply-test+ebwbfyuwb@digital.blah.com
const SEED = Math.random().toString(36).substring(2, 15);

describe(`[${ENVIRONMENT}] Candidate`, () => {
  it("can sign up successfully", () => {
    givenIAmOnTheHomePage();
    andItIsAccessible();
    whenIChooseToCreateAnAccount();
    if (isBetweenCycles()) {
      return thenIShouldBeToldThatApplicationsAreClosed();
    }
    thenICanCreateAnAccount();

    whenITypeInMyEmail();
    andIClickContinue();
    thenIAmToldToCheckMyEmail();

    whenIClickTheLinkInMyEmail();
    andIClickSignIn();
    thenIShouldBeSignedInSuccessfully();
  });
});

const givenIAmOnTheHomePage = () => {
  cy.visit("/candidate/account");
  cy.contains("Create an account or sign in");
};

const andItIsAccessible = () => {
  cy.runAxe();
};

const whenIChooseToCreateAnAccount = () => {
  cy.contains("No, I need to create an account").click();
  cy.contains("Continue").click();
};

const andIClickContinue = () => {
  cy.contains("Continue").click();
};

const andIClickSignIn = () => {
  cy.get("button").contains("Accept analytics cookies").click();
  cy.get("button").contains(/Sign in|Create account/).click();
};

const thenICanCreateAnAccount = () => {
  cy.contains("Create an account");
};

const whenITypeInMyEmail = () => {
  cy.get("#candidate-interface-sign-up-form-email-address-field").type(
    candidateEmailAddress()
  );
};

const thenIAmToldToCheckMyEmail = () => {
  cy.contains("Check your email");
};

const whenIClickTheLinkInMyEmail = () => {
  cy.task("getSignInLinkFor", { emailAddress: candidateEmailAddress() }).then(
    signInLink => {
      cy.visit(signInLink);
    }
  );
};

const thenIShouldBeSignedInSuccessfully = () => {
  cy.contains("Sign out");
};

const isBetweenCycles = () => {
  const endOfCycle = +new Date(2020, 7, 25);
  const startOfNewCycle = +new Date(2020, 9, 13);
  const currentTime = +new Date();

  return currentTime > endOfCycle && currentTime < startOfNewCycle;
};

const thenIShouldBeToldThatApplicationsAreClosed = () => {
  cy.contains("Applications for courses starting this year have closed.");
};

const isSandbox = () => ENVIRONMENT.toUpperCase() === "SANDBOX";

const candidateEmailAddress = () => {
  const [name, domain] = CANDIDATE_EMAIL.split('@');
  return `${name}+${SEED}@${domain}`;
}
