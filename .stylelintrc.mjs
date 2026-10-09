import propertyGroups from 'stylelint-config-recess-order/groups'

export default {
  extends: ["stylelint-config-gds/scss", "stylelint-config-recess-order"],
  plugins: ["stylelint-order"],
  rules: {
    // Configure the rule manually.
    "order/properties-order": propertyGroups.map((group) => ({
      ...group,
      emptyLineBefore: "always",
      noEmptyLineBetween: true,
    })),
    // Stylelint 17 resolves nesting per the CSS spec, so SCSS BEM suffixes
    // like `&__item` are read as type selectors (`__item.block`). The rule is
    // documented as CSS-only, so disable it for our SCSS.
    "selector-no-qualifying-type": null,
    "value-keyword-case": [
      "lower",
      {
        camelCaseSvgKeywords: true,
      },
    ],
  },
};
