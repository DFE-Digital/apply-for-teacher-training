module CandidateInterface
  class NoDegreeComponent < ApplicationComponent
    attr_reader :application_form, :editable

    def initialize(application_form:, editable:)
      @application_form = application_form
      @editable = editable
    end

    def rows
      [
        {
          key: 'Do you have a university degree?',
          value: 'No, I do not have a degree',
          action: { href: candidate_interface_degree_university_degree_path },
        },
      ]
    end
  end
end
