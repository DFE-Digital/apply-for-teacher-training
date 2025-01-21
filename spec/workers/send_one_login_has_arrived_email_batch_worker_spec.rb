require 'rails_helper'

RSpec.describe SendOneLoginHasArrivedEmailBatchWorker do
  describe '#perform' do
    it 'enqueues candidate emails' do
      application_forms = create_list(:application_form, 2)

      expect { described_class.new.perform(application_forms.pluck(:id)) }
        .to have_enqueued_mail(CandidateMailer, :one_login_has_arrived).twice
    end
  end
end
