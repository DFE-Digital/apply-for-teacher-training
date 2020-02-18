RSpec::Matchers.define :have_submit_button do |value|
  match do
    page.has_selector?("input[type=submit][value='#{value}']")
  end
end
