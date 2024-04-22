# View components

We use [ViewComponent](https://github.com/github/view_component) for reusable view components.

## Why use components?

The [guide section in the ViewComponent README has detailed explanations](https://github.com/github/view_component#guide), but in a nutshell these are some pros:

- They are easy to unit test
- They are easy to make and reuse
- They can be used to wrap things like GOV.UK Design System components
- They allow you to couple Ruby logic with a Rails partial without having to write the logic inside `erb`
- They are 5x faster to render than partials
- They can be previewed on their own and are easy to "Design Systemify"

## When to use components

The prime use-case for components are reusable elements and widgets, such as:

- a button
- a phase tag
- a customised details element
- a breadcrumb
- an accordion widget (parent element + the items)

You can compose components and call components inside of other components.

You can also use components to render an entire page. This is the status quo in JS frameworks like React. However, big components are unwieldy and not as reusable. You can start with a regular view, and break off parts of it into components if you want better unit testing capabilities or reusability.

You cannot use components for atomic things, like a component that renders just a formatted date string. At the time of writing it seems like using a `render` call with a component will also add HTML newlines before and after. The spacing cannot be removed using `.strip`, because it's an HTMLBuffer type object instead of a string.

A `ViewHelper` is likely a better choice for something as atomic as this, but this could change in the future.

## Comparison to view helpers

You should use components over view helpers if you need to compose HTML, because nested `content_tag`s are harder to read than ERB.

To use view helpers in your components, include this at the top of the class declaration:

```ruby
include ViewHelper
```

## Comparison to presenters

[Presenters/Decorators/ViewModels](https://nithinbekal.com/posts/rails-presenters/) are plain classes that encapsulate view/"presentational" logic. They are used to lighten up models and reuse logic between different views.

Presenters sit at a higher level than components. You can have presenters that feed in pre-munged data into components. But components are classes in and of themselves and are capable of doing the same data transformation operations that a presenter could do.

We've used presenters in the early days of the codebase, but now recommend using components where possible.

## Using route paths in component `.rb` files

You have to call e.g. `Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_base_path` which is a bit unwieldy.

## Examples of components

- `HeaderComponent`: [header_component.rb](../app/components/header_component.rb), [header_component.html.erb](../app/components/header_component.html.erb), [header_component_spec.rb](../spec/components/header_component_spec.rb)
- `DfESignInButtonComponent`: [dfe_sign_in_button_component.rb](../app/components/dfe_sign_in_button_component.rb), [dfe_sign_in_button_component.html.erb](../app/components/dfe_sign_in_button_component.html.erb), [dfe_sign_in_button_component_spec.rb](../spec/components/dfe_sign_in_button_component_spec.rb)
