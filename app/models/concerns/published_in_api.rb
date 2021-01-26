module PublishedInAPI
  extend ActiveSupport::Concern

  included do
    after_commit do
      application_form.application_choices.touch_all
    end
  end
end
