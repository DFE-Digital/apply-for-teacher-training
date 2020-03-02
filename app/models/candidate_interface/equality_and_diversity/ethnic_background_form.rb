module CandidateInterface
  class EqualityAndDiversity::EthnicBackgroundForm
    include ActiveModel::Model

    attr_accessor :ethnic_background, :other_background

    validates :ethnic_background, presence: true

    def self.build_from_application(application_form)
      group = application_form.equality_and_diversity['ethnic_group']
      background = application_form.equality_and_diversity['ethnic_background']

      return new if background.nil?

      if listed_ethnic_background?(group, background)
        new(ethnic_background: application_form.equality_and_diversity['ethnic_background'])
      else
        new(
          ethnic_background: EthnicBackgroundHelper::OTHER_ETHNIC_BACKGROUNDS[group].first,
          other_background: application_form.equality_and_diversity['ethnic_background'],
        )
      end
    end

    def save(application_form)
      return false unless valid?

      group = application_form.equality_and_diversity['ethnic_group']

      other_background_present = ethnic_background == EthnicBackgroundHelper::OTHER_ETHNIC_BACKGROUNDS[group].first && other_background.present?

      background = other_background_present ? other_background : ethnic_background

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'ethnic_background' => background })
      else
        application_form.equality_and_diversity['ethnic_background'] = background
        application_form.save
      end
    end

    def self.listed_ethnic_background?(group, background)
      EthnicBackgroundHelper::ETHNIC_BACKGROUNDS[group].include?(background) || EthnicBackgroundHelper::OTHER_ETHNIC_BACKGROUNDS[group].include?(background)
    end
  end
end
