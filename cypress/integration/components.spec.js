const ENVIRONMENT = Cypress.env("ENVIRONMENT") || "Unknown";

describe(`[${ENVIRONMENT}] Components`, () => {
  it("are accessible", () => {
    givenIAmOnTheComponentReviewPage();
    thenEachComponentShouldBeAccessible();
  });
});

const givenIAmOnTheComponentReviewPage = () => {
  cy.visit("/rails/view_components");
  cy.contains("Candidate Interface/Application Status Tag Component");
};

const thenEachComponentShouldBeAccessible = () => {
  cy.get("li a").then((tags) => {
    const hrefs = Array.from(tags).map((t) => t.href);
    hrefs.forEach((href) => {
      cy.visit(href);
      thenItShouldBeAccessible();
    });
  });
};

const thenItShouldBeAccessible = () => {
  cy.runAxe();
};
