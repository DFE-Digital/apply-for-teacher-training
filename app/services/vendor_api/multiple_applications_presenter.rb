module VendorApi
  class MultipleApplicationsPresenter
    attr_reader :application_choices

    def initialize(application_choices)
      @application_choices = application_choices
    end

    def as_json
      application_choices.map do |application_choice|
        SingleApplicationPresenter.new(application_choice).as_json
      end
    end
  end
end
