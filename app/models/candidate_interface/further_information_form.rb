module CandidateInterface
  class FurtherInformationForm
    include ActiveModel::Model

    attr_accessor :further_information, :further_information_details

    validates :further_information, presence: true
    validates :further_information_details, presence: true, if: :further_information?

    validates :further_information_details, word_count: { maximum: 300 }

    def save(application_form)
      return false unless valid?

      application_form.update(
        further_information: further_information?,
        further_information_details: further_information? ? further_information_details : '',
      )
    end

    def further_information?
      further_information == 'true'
    end
  end
end
