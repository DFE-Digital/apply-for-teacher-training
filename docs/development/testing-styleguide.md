# Testing styleguide

We ["FutureLearn style" acceptance tests](https://web.archive.org/web/20160801112733/https://about.futurelearn.com/blog/how-we-write-readable-feature-tests-with-rspec/).

## Rules

1. Use a single scenario per file. This prevents the files from becoming too large. Separate logical blocks of steps with newlines.
2. Use instance variable to carry state between steps. Do not use `let` or `before` blocks.
3. Define all steps in the file. If you want to share code between scenarios, call helpers that are defined in a module from the step.
4. The steps should be written in English. Do not use parameters to call the step methods.

## Timetravel

In CI, we run our test suite with offset-dates to ensure tests won't break as we encounter different milestones in the cycle.
If you are writing a test for something that only works during some points in the cycle, you will need to make that explicit in your test by setting the time in the describe / scenario block. eg `time: mid_cycle`
To run the tests locally with different offset dates, you can set the TEST_DATE_AND_TIME env var, eg:
`TEST_DATE_AND_TIME='before_apply_reopens' bundle exec rspec spec/some_spec.rb`
The options for `TEST_DATE_AND_TIME` are `real_world, after_apply_deadline, before_apply_reopens, after_apply_reopens`

## Examples

A good test looks like this:

```rb
# do_a_thing_feature_spec.rb
RSpec.describe 'Do a thing feature' do
  include TestHelpers

  scenario 'User does a thing', time: mid_cycle do
    given_i_am_signed_in
    when_i_press_a_button
    then_something_should_happen
  end

  def given_i_am_signed_in
    @user = create(:user)
    sign_in(@user)
  end

  def when_i_press_a_button
    click_link_or_button 'Do the thing'
  end

  def then_something_should_happen
    expect(@user).to have(done_something)
  end
end

# helpers.rb
module TestHelpers
  def sign_in(user)
    # do the thing
  end
end
```

A less good test looks like this:

```rb
# do_a_thing_feature_spec.rb
RSpec.describe 'Do a thing feature' do
  include TestHelpers

  let(:user) { create(:user) } # Bad: a `let` block adds noise to the file and adds indirection

  # Bad: a `before` block adds noise to the file and can make it unclear why something is set up
  before do
    sign_in_user(user)
  end

  scenario 'User does a thing' do
    when_i_press_a_button('Do the thing') # Bad: a parameterised method makes the step harder to read
    then_something_should_happen # Bad: hidden in a module
  end

  # Bad: multiple scenarios clutter the file and slow down the test suite
  scenario 'User does a different thing' do
    when_i_press_a_button('Do the thing') # Bad: a parameterised method makes the step harder to read
    then_something_else_should_happen # Bad: hidden in a module
  end

  # Bad: a parameterised method
  def when_i_press_a_button(text)
    click_link_or_button(text)
  end

  def then_something_else_should_happen
    expect(@user).to have(done_something_else)
  end
end

# helpers.rb
module TestHelpers
  def then_something_should_happen
    expect(@user).to have(done_something)
  end
end
```
