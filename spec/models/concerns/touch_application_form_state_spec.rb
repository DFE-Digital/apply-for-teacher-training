require 'rails_helper'

RSpec.describe TouchApplicationFormState do
  describe 'before_save' do
    context 'application choice is created and the application form has not been updated' do
      it 'updates the candidate_api_updated_at' do
        application_form = create(:application_form)

        expect { create(:application_choice, :unsubmitted, application_form: application_form) }
          .to(change { application_form.candidate.candidate_api_updated_at })
      end
    end

    context 'application choice is created and the application form has been updated' do
      it 'does not update the candidate_api_updated_at' do
        application_form = create(:application_form, created_at: 1.day.ago)

        expect { create(:application_choice, :unsubmitted, application_form: application_form) }
          .not_to(change { application_form.candidate.candidate_api_updated_at })
      end
    end

    context 'application qualification is created and the application form has not been updated' do
      it 'updates the candidate_api_updated_at' do
        application_form = create(:application_form)

        expect { create(:application_qualification, application_form: application_form) }
          .to(change { application_form.candidate.candidate_api_updated_at })
      end
    end

    context 'application qualification is created and the application form has been updated' do
      it 'does not update the candidate_api_updated_at' do
        application_form = create(:application_form, created_at: 1.day.ago)

        expect { create(:application_qualification, application_form: application_form) }
          .not_to(change { application_form.candidate.candidate_api_updated_at })
      end
    end

    context 'reference is created and the application form has been updated' do
      it 'updates the candidate_api_updated_at' do
        application_form = create(:application_form)

        expect { create(:reference, application_form: application_form) }
          .to(change { application_form.candidate.candidate_api_updated_at })
      end
    end

    context 'reference is created and the application form has not been updated' do
      it 'does not update the candidate_api_updated_at' do
        application_form = create(:application_form, created_at: 1.day.ago)

        expect { create(:reference, application_form: application_form) }
          .not_to(change { application_form.candidate.candidate_api_updated_at })
      end
    end
  end
end
