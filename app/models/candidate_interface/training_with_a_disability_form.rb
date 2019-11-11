module CandidateInterface
  class TrainingWithADisabilityForm
    include ActiveModel::Model

    attr_accessor :disclose_disability, :disability_disclosure

    validates_inclusion_of :disclose_disability, in: [true, false, 'true', 'false']

    def self.build_from_application(application_form)
      new(
        disclose_disability: application_form.disclose_disability,
        disability_disclosure: application_form.disability_disclosure,
      )
    end

    def save(application_form)
      return false unless valid?

      # explicitly null-out the text field if the user said 'No'
      # so that we don't need to add the boolean field to the API:
      # it just returns null if they said No
      # Note also that we can't just test for == false, due to how Ruby / Rails
      # manage string parameters & implicit type conversions
      self.disability_disclosure = nil if self.disclose_disability.to_s == 'false'

      application_form.update!(
        disclose_disability: self.disclose_disability,
        disability_disclosure: self.disability_disclosure,
      )
    end
  end
end
