module CandidateInterface
  class EqualityAndDiversity::FreeSchoolMealsForm
    include ActiveModel::Model

    attr_accessor :free_school_meals

    validates :free_school_meals, presence: true

    def self.build_from_application(application_form)
      return new(free_school_meals: nil) if application_form.equality_and_diversity.nil?
      return new(free_school_meals: nil) if application_form.equality_and_diversity['free_school_meals'].nil?

      new(free_school_meals: application_form.equality_and_diversity['free_school_meals'])
    end

    def save(application_form)
      return false unless valid?

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'free_school_meals' => free_school_meals })
      else
        application_form.equality_and_diversity['free_school_meals'] = free_school_meals
        application_form.save
      end
    end
  end
end
