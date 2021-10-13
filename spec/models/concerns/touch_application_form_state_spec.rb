require 'rails_helper'

RSpec.describe TouchApplicationFormState do
  describe 'around_save' do
    context 'when the application form is updated and the state changes' do
      it 'updates the candidate_api_updated_at' do
        application_form = create(:application_form)

        Timecop.travel(1.hour.from_now) do
          expect { application_form.update(first_name: 'David') }
            .to(change { application_form.candidate.candidate_api_updated_at })
        end
      end

      context 'when the application form is updated and the state does not change' do
        it 'does not update the candidate_api_updated_at' do
          application_form = create(:application_form, created_at: 1.day.ago)

          expect { application_form.update(first_name: 'David') }
            .not_to(change { application_form.candidate.candidate_api_updated_at })
        end
      end

      context 'application choice is created and it updates the application state' do
        it 'updates the candidate_api_updated_at' do
          application_form = create(:application_form)

          Timecop.travel(1.hour.from_now) do
            expect { create(:application_choice, :unsubmitted, application_form: application_form) }
              .to(change { application_form.reload.candidate.candidate_api_updated_at })
          end
        end
      end

      context 'application choice is created and it does not update the application state' do
        it 'does not update the candidate_api_updated_at' do
          application_form = create(:application_form, created_at: 1.day.ago)

          expect { create(:application_choice, :unsubmitted, application_form: application_form) }
            .not_to(change { application_form.candidate.candidate_api_updated_at })
        end
      end

      context 'application qualification is created and it updates the application state' do
        it 'updates the candidate_api_updated_at' do
          application_form = create(:application_form)

          Timecop.travel(1.hour.from_now) do
            expect { create(:application_qualification, application_form: application_form) }
              .to(change { application_form.reload.candidate.candidate_api_updated_at })
          end
        end
      end

      context 'application qualification is updated and it does not update the application state' do
        it 'does not update the candidate_api_updated_at' do
          application_form = create(:application_form, created_at: 1.day.ago)

          expect { create(:application_qualification, application_form: application_form) }
            .not_to(change { application_form.candidate.candidate_api_updated_at })
        end
      end

      context 'reference is created and it updates the application state' do
        it 'updates the candidate_api_updated_at' do
          application_form = create(:application_form)

          Timecop.travel(1.hour.from_now) do
            expect { create(:reference, application_form: application_form) }
              .to(change { application_form.reload.candidate.candidate_api_updated_at })
          end
        end
      end

      context 'reference is updated and it does not update the application state' do
        it 'does not update the candidate_api_updated_at' do
          application_form = create(:application_form, created_at: 1.day.ago)

          expect { create(:reference, application_form: application_form) }
            .not_to(change { application_form.candidate.candidate_api_updated_at })
        end
      end
    end
  end
end
