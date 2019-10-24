module CandidateInterface
  class ContactDetailsForm
    include ActiveModel::Model

    attr_accessor :phone_number

    def self.build_from_application(application_form)
      new(phone_number: application_form.phone_number)
    end

    def save(application_form)
      application_form.update(phone_number: phone_number)
    end
  end
end
