const propertyGroups = require("stylelint-config-recess-order/groups");

module.exports = {
  extends: ["stylelint-config-gds/scss", "stylelint-config-recess-order"],
  plugins: ["stylelint-order"],
  rules: {
    // Configure the rule manually.
    "order/properties-order": propertyGroups.map((group) => ({
      ...group,
      emptyLineBefore: "always",
      noEmptyLineBetween: true,
    })),
    "value-keyword-case": [
      "lower",
      {
        camelCaseSvgKeywords: true,
      },
    ],
  },
};
