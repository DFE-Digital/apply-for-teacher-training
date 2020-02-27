module CandidateInterface
  class EqualityAndDiversity::EthnicBackgroundForm
    include ActiveModel::Model

    ETHNIC_BACKGROUNDS = {
      'Asian or Asian British' => %w[Bangladeshi Chinese Indian Pakistani],
      'Black, African, Black British or Caribbean' => %w[African Carribean],
      'Mixed or multiple ethnic groups' => ['Asian and White', 'Black African and White', 'Black Caribbean and White'],
      'White' => ['British, English, Northern Irish, Scottish, or Welsh', 'Irish', 'Irish Traveller or Gypsy'],
      'Another ethnic group' => %w[Arab],
    }.freeze

    attr_accessor :ethnic_background, :other_background

    validates :ethnic_background, presence: true

    def self.build_from_application(application_form)
      group = application_form.equality_and_diversity['ethnic_group']
      background = application_form.equality_and_diversity['ethnic_background']

      if ETHNIC_BACKGROUNDS[group].include?(background) || background == "Another #{group} background"
        new(ethnic_background: application_form.equality_and_diversity['ethnic_background'])
      else
        new(
          ethnic_background: "Another #{group} background",
          other_background: application_form.equality_and_diversity['ethnic_background'],
        )
      end
    end

    def save(application_form)
      return false unless valid?

      group = application_form.equality_and_diversity['ethnic_group']

      background = ethnic_background == "Another #{group} background" && other_background.present? ? other_background : ethnic_background

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'ethnic_background' => background })
      else
        application_form.equality_and_diversity['ethnic_background'] = background
        application_form.save
      end
    end
  end
end
