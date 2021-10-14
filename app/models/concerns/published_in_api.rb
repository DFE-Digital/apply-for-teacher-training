module PublishedInAPI
  extend ActiveSupport::Concern

  included do
    after_commit do
      application_form.touch_choices
    end
  end
end
