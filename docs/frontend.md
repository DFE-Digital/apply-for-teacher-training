# Frontend development

Our services use the [GOV.UK Design System](https://design-system.service.gov.uk). We implement this by using [GOV.UK Components](https://github.com/dfE-Digital/govuk-components), [GOV.UK Form Builder](https://govuk-form-builder.netlify.app) alongside several [view helpers](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/helpers/view_helper.rb). CSS and JavaScript is provided by [govuk-frontend](https://github.com/alphagov/govuk-frontend).

Using these components and helpers means that there shouldn’t be a need to write any HTML, CSS or JavaScript. For example, using `f.govuk_submit` for submit buttons (or `govuk_link_to` for links) means these elements use the correct attributes, are styled correctly – and require less code.

When creating new components, use the following guidelines.

## Browser support

See [Designing for different browsers and devices](https://www.gov.uk/service-manual/technology/designing-for-different-browsers-and-devices) in the GOV.UK Service Manual for a list of browsers we support.

## Accessibility

The code we write needs to be accessible to all. Our services are regularly audited, but we try to ensure that no regressions are introduced when we add new features.

### Common mistakes

- Pages should have unique titles.

- If a page contains a form, the page title should be prefixed with ‘Error: ’ if any of its fields need validating. Use `title_with_error_prefix` helper to ensure this prefix appears when there are errors.

- Error summaries should appear before the page heading.

- Ensure change links have visually-hidden text to disambiguate them. The same applies to other links that share the same visible name.

## HTML

We [follow the GDS Way for writing HTML](https://gds-way.cloudapps.digital/manuals/programming-languages/html.html).

This means using HTML5 to structure pages semantically. For example, use `<p>` for paragraphs and `<ul>` for unordered lists.

Pay particular attention to headings. There should only be one `<h1>` element on a page. Headings should usually be nested in order - for example `<h2>` is followed by `<h3>`, not `<h4>`. If you are creating a component that can appear in different parts of a page, ensure that any heading levels can be customised.

Attributes should use double quotes.

Add GOV.UK Design System classes to all elements, such as `govuk-body` for `<p>` and govuk-link for `<a>`. This isn’t necessary in the prototyping kit, but is in production, and can help avoid mistakes if the HTML is copied across.

Use the `govuk_link_to` (or `govuk_mail_to`) helper for links.

### Class names

We use BEM notation and [follow GDS conventions](https://design-system.service.gov.uk/get-started/extending-and-modifying-components/):

- Prefix application-specific styles with `app-*`

- Prefix application-specific style overrides with `app-!-*`

- Modify classes provided by `govuk-frontend` by using the same namespace prefixed with `app-*` and suffixed with an explicitly named modifier.

  For example, to create a version of the tag component with a new colour, use 2 classes: the base class and an application-specific modifier:

  ```html
  <strong class="govuk-tag app-tag--peach">My new tag</strong>
  ```

  If the modification is significant, fork the component and replace all `govuk-*` prefixes with `app-*` (and consider renaming the component).

- Prefix JavaScript hooks with `js-*` (although the Design System convention is to use `data-module` attributes instead).

## CSS

We [follow the same conventions for writing CSS as used by `govuk-frontend`](https://github.com/alphagov/govuk-frontend/blob/main/docs/contributing/coding-standards/css.md). We lint styles using [Stylelint](https://stylelint.io) and the rules set out in the `stylint-config-gds` configuration. We use Sass to preprocess CSS files.

Avoid writing CSS where possible – use the standard styles, components and overrides from the [GOV.UK Design System](https://design-system.service.gov.uk) instead.

### Sass

When writing new styles, [use the helpers and mixins provided by `govuk-frontend`](https://frontend.design-system.service.gov.uk/sass-api-reference/).

Stylesheets are organised by the interface they are used by. This ensures that we only serve styles to the users that require them, keeping the overall size of our assets to a minimum.

| Interface                            | Styles                          |
| ------------------------------------ | ------------------------------- |
| Shared                               | `app/frontend/styles`           |
| API docs                             | `app/frontend/styles/api_docs`  |
| Apply for teacher training           | `app/frontend/styles/candidate` |
| Manage teacher training applications | `app/frontend/styles/provider`  |
| Support for apply                    | `app/frontend/styles/support`   |

We keep imports ordered alphabetically (using BEM notation means styles are encapsulated, meaning the order in which styles are imported shouldn’t matter).

## JavaScript

We [follow the same conventions for writing JS as used by `govuk-frontend`](https://github.com/alphagov/govuk-frontend/blob/main/docs/contributing/coding-standards/js.md). We lint JavaScript using [StandardJS](https://standardjs.com).

Individual JavaScript modules are bundled together and served only to the interface they are used by. This ensures that we only serve JavaScript to the users that require it, keeping the overall size of our assets to a minimum.

| Interface                            | JavaScript entry point                        |
| ------------------------------------ | --------------------------------------------- |
| Shared                               | `app/frontend/packs/application.js`           |
| API docs                             | `app/frontend/packs/application-api-docs.js`  |
| Apply for teacher training           | `app/frontend/packs/application-candidate.js` |
| Manage teacher training applications | `app/frontend/packs/application-provider.js`  |
| Support for apply                    | `app/frontend/packs/application-support.js`   |

### jQuery

Avoid using jQuery. Browser support for ES5 JavaScript is now widespread enough that a library like jQuery is unnecessary.

### Testing

We test JavaScript using [Jest](https://jestjs.io). We also have system specs which test JavaScript using a Chromium headless browser and Capybara.

Spec files should be saved alongside the corresponding JavaScript file.

## Asset pipeline

We use the Rails webpack wrapper [Webpacker](https://github.com/rails/webpacker) to compile CSS, images, fonts and JavaScript.

## Debugging Webpacker

Webpacker sometimes does not give clear indications of what’s wrong when it does not work.

If you see repeated `Webpacker compiling…` messages in the Rails server log, a good place to start debugging is by running the webpack compiler via `bin/webpack`. This will give a much faster feedback loop than making requests using a web browser.

If you get `Webpacker::Manifest::MissingEntryError`s, this usually points to a problem in the compilation process which is causing one or more files not to be created. Make sure that your Yarn packages are up to date using `yarn check` before proceeding to debug using `bin/webpack`.

If assets work in dev but not in tests, first confirm that you can compile by invoking `bin/webpack`. If all is well, there is a chance that `public/packs-test` contains stale output. Delete it and re-run the suite.

If you get 404s on assets, but they compile okay or exist in `public/packs`, it is likely that `webpack-dev-server` is running in another project. Our app is configured to look for `webpack-dev-server` on the default port, which other services may also use. Change the port in `config/webpacker.yml` or quit other Webpacker servers.
