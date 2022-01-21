// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

function terminalLog(violations) {
  const vl = violations.length;
  const xA11yViolations = `${vl} accessibility violation${vl === 1 ? "" : "s"}`;
  const wereDetected = ` ${vl === 1 ? "was" : "were"} detected`;
  cy.task("log", xA11yViolations + wereDetected);

  const violationData = violations.map(
    ({ id, impact, description, nodes }) => ({
      id,
      impact,
      description,
      nodes: nodes.length,
    })
  );

  cy.task("table", violationData);
}

Cypress.Commands.add("runAxe", () => {
  cy.injectAxe();
  cy.configureAxe({
    // https://github.com/alphagov/govuk-frontend/issues/979
    // This issue is present on forms with conditional checkboxes, such as the
    // candidate sign up form. Axe will complain that these inputs shouldn't
    // have an aria-expanded attribute. However, the design system currently
    // still uses this attribute, as it does help on devices such as NVDA.
    // Disable the rule to prevent Axe from bringing it up.
    rules: [{ id: 'aria-allowed-attr', enabled: false }],
  })
  cy.checkA11y(
    {
      exclude: [["#navigation", "ul"]],
    },
    {
      includedImpacts: ["critical", "serious"],
    },
    terminalLog
  );
});
