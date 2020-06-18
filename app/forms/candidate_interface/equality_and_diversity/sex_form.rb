module CandidateInterface
  class EqualityAndDiversity::SexForm
    include ActiveModel::Model

    attr_accessor :sex

    validates :sex, presence: true

    def self.build_from_application(application_form)
      sex = application_form.equality_and_diversity ? application_form.equality_and_diversity['sex'] : nil

      new(sex: sex)
    end

    def save(application_form)
      return false unless valid?

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'sex' => sex })
      else
        application_form.equality_and_diversity['sex'] = sex
        application_form.save
      end
    end
  end
end
