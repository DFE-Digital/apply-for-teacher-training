module CandidateInterface
  class EqualityAndDiversity::DisabilityStatusForm
    include ActiveModel::Model

    attr_accessor :disability_status

    validates :disability_status, presence: true

    def self.build_from_application(application_form)
      return new(disability_status: nil) if application_form.equality_and_diversity.nil?
      return new(disability_status: nil) if application_form.equality_and_diversity['disabilities'].nil?
      return new(disability_status: 'yes') if application_form.equality_and_diversity['disabilities'].any?

      new(disability_status: 'no')
    end

    def save(application_form)
      return false unless valid?

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'disabilities' => [] })
      else
        application_form.equality_and_diversity['disabilities'] = []
        application_form.save
      end
    end
  end
end
