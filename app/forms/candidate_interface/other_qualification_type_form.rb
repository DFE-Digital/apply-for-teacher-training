module CandidateInterface
  class OtherQualificationTypeForm
    include ActiveModel::Model

    attr_accessor :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type

    validates :qualification_type, presence: true

    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == 'Other' }

    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == 'non_uk' }

    validates :qualification_type, inclusion: { in: ['A level', 'AS level', 'GCSE', 'Other', 'non_uk'], allow_blank: false }

    def save(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels[:other],
        qualification_type: qualification_type,
        other_uk_qualification_type: other_uk_qualification_type,
        non_uk_qualification_type: non_uk_qualification_type,
      )
      true
    end

    def update(qualification)
      return false unless valid?

      qualification.update!(
        qualification_type: qualification_type,
        other_uk_qualification_type: set_other_uk_qualification_type,
        non_uk_qualification_type: set_non_uk_qualification_type,
      )
    end

    def self.build_from_qualification(qualification)
      new(
        qualification_type: qualification.qualification_type,
        other_uk_qualification_type: qualification.other_uk_qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
      )
    end

  private

    def set_other_uk_qualification_type
      qualification_type == 'Other' ? other_uk_qualification_type : nil
    end

    def set_non_uk_qualification_type
      qualification_type == 'non_uk' ? non_uk_qualification_type : nil
    end
  end
end
