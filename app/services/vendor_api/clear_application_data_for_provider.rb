module VendorAPI
  class ClearApplicationDataForProvider
    def self.call(provider)
      scope = Candidate.joins(application_forms: { application_choices: { course_option: :course } })
      scope.where("courses.accredited_provider": provider).or(scope.where("courses.provider": provider))
        .delete_all
    end
  end
end
