module CandidateInterface
  class OtherQualificationTypeForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :qualification_type
    attribute :other_uk_qualification_type
    attribute :non_uk_qualification_type

    validates :qualification_type, presence: true
    validates :qualification_type, inclusion: { in: ['A level', 'AS level', 'GCSE', 'Other', 'non_uk'], allow_blank: false }
    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == 'Other' && FeatureFlag.active?('international_other_qualifications') }
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == 'non_uk' }
  end
end
