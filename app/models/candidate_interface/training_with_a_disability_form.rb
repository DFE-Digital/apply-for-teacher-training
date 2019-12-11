module CandidateInterface
  class TrainingWithADisabilityForm
    include ActiveModel::Model

    attr_accessor :disclose_disability, :disability_disclosure

    validates_inclusion_of :disclose_disability, in: %w[yes no]

    validates :disability_disclosure,
              word_count: { maximum: 400 },
              allow_blank: true

    def self.build_from_application(application_form)
      new(
        disclose_disability: boolean_to_word(application_form.disclose_disability),
        disability_disclosure: application_form.disability_disclosure,
      )
    end

    def save(application_form)
      return false unless valid?

      # explicitly null-out the text field if the user said 'No'
      # so that we don't need to add the boolean field to the API:
      # it just returns null for the text field if they said No
      self.disability_disclosure = nil if self.disclose_disability.to_s == 'no'

      application_form.update!(
        disclose_disability: yes_no_to_boolean(self.disclose_disability),
        disability_disclosure: self.disability_disclosure,
      )
    end

    def self.boolean_to_word(boolean)
      return nil if boolean.nil?

      boolean ? 'yes' : 'no'
    end

  private

    def yes_no_to_boolean(value)
      if value == 'yes'
        true
      elsif value == 'no'
        false
      end
      # nil by default
    end
  end
end
