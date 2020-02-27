module CandidateInterface
  class EqualityAndDiversity::EthnicGroupForm
    include ActiveModel::Model

    attr_accessor :ethnic_group

    validates :ethnic_group, presence: true

    def self.build_from_application(application_form)
      return new(ethnic_group: nil) if application_form.equality_and_diversity.nil?
      return new(ethnic_group: nil) if application_form.equality_and_diversity['ethnic_group'].nil?

      new(ethnic_group: application_form.equality_and_diversity['ethnic_group'])
    end

    def save(application_form)
      return false unless valid?

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'ethnic_group' => ethnic_group })
      else
        application_form.equality_and_diversity['ethnic_group'] = ethnic_group
        application_form.equality_and_diversity['ethnic_background'] = nil if ethnic_group == 'Prefer not to say'
        application_form.save
      end
    end
  end
end
