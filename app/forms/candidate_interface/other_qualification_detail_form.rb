module CandidateInterface
  class OtherQualificationDetailForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :intermediate_data_service, :next_step
    attr_accessor :checking_answers, :id, :current_step

    attribute :qualification_type
    attribute :other_uk_qualification_type
    attribute :non_uk_qualification_type

    validates :qualification_type, presence: true
    validates :qualification_type, inclusion: { in: ['A level', 'AS level', 'GCSE', 'Other', 'non_uk'], allow_blank: false }
    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == 'Other' && FeatureFlag.active?('international_other_qualifications') }
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == 'non_uk' }

    def initialize(intermediate_data_service, options)
      @intermediate_data_service = intermediate_data_service
      super(options)
    end

    def save!
      if checking_answers && !qualification_type_changed?
        current_qualification.update!(attributes_for_persistence)
        @next_step = :check
      else
        intermediate_data_service.write(intermediate_state)
        @next_step = :details
      end
    end

  private

    def attributes_for_persistence
      {
        qualification_type: qualification_type,
        other_uk_qualification_type: other_uk_qualification_type,
        non_uk_qualification_type: non_uk_qualification_type,
      }
    end

    def intermediate_state
      as_json(
        only: %w[id current_step checking_answers qualification_type other_uk_qualification_type non_uk_qualification_type],
      )
    end

    def intermediate_data_service
      @intermediate_data_service ||= IntermediateDataService.new(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
      )
    end
    
    def qualification_type_changed?
      id && ApplicationQualification.find(id)&.qualification_type != qualification_type
    end
  end
end
