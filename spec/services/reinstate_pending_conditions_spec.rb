require 'rails_helper'

RSpec.describe ReinstatePendingConditions do
  subject(:service) do
    described_class.new(actor: provider_user,
                        application_choice:,
                        course_option: new_course_option,
                        offer_changed: false)
  end

  let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:original_course) { create(:course, :previous_year_but_still_available, provider:) }
  let(:previous_course_option) { create(:course_option, course: original_course) }
  let(:new_course_option) { create(:course_option, course: original_course.in_next_cycle) }
  let(:application_choice) { create(:application_choice, :offer_deferred, course_option: previous_course_option) }

  it 'changes application status to \'pending_conditions\'' do
    expect { service.save! }.to change(application_choice, :status).to('pending_conditions')
  end

  it 'changes current_course_option_id for the application choice' do
    expect { service.save! }.to change(application_choice, :current_course_option_id)
  end

  it 'sets recruited_at to nil if conditions are no longer met' do
    application_choice.update(
      status_before_deferral: 'recruited',
      recruited_at: application_choice.accepted_at + 7.days,
    )

    expect { service.save! }.to change(application_choice, :recruited_at).to(nil)
  end

  it 'updates the status of all conditions to pending' do
    application_choice.offer.conditions.update(status: :met)

    expect { service.save! }.to change { application_choice.offer.conditions.first.status }.from('met').to('pending')
  end

  context 'when the application does not have an offer object associated' do
    let(:application_choice) do
      create(:application_choice,
             :offered,
             :offer_deferred,
             status_before_deferral: :pending_conditions,
             course_option: previous_course_option)
    end

    it 'creates an offer object' do
      service.save!

      expect(application_choice.offer).not_to be_nil
      expect(application_choice.offer.conditions.first.status).to eq('pending')
    end
  end

  describe 'other dependencies' do
    it 'calls update_course_option_and_associated_fields!' do
      allow(application_choice).to receive(:update_course_option_and_associated_fields!)
      service.save!
      expect(application_choice).to have_received(:update_course_option_and_associated_fields!)
    end
  end

  describe 'validations' do
    it_behaves_like 'confirm deferred offer validations', :reinstate_pending_conditions
  end

  context 'when offer_changed is false by default' do
    subject(:service) do
      described_class.new(
        actor: provider_user,
        application_choice:,
        course_option: new_course_option,
        offer_changed: false,
      )
    end

    it 'sends reinstated offer email with correct content', :sidekiq do
      new_course_option.course.update!(start_date: original_course.start_date + 1.year)

      expect {
        service.save!
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.body.raw_source).to include(new_course_option.course.start_date.to_fs(:month_and_year))
      expect(email.subject).to include("[TEST] Your deferred offer to study #{application_choice.course.name_and_code} has been confirmed by #{application_choice.provider.name}")
      expect(email.to).to include(application_choice.application_form.candidate.email_address)

      expect(email.body.raw_source).to include('Sign in to your account to check the progress of your offer conditions.')
    end
  end

  context 'when offer_changed is true' do
    subject(:service) do
      described_class.new(
        actor: provider_user,
        application_choice:,
        course_option: new_course_option,
        offer_changed: true,
      )
    end

    it 'sends the deferred_offer_new_details email', :sidekiq do
      expect {
        service.save!
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.body.raw_source).to include(new_course_option.course.start_date.to_fs(:month_and_year))
      expect(email.subject).to include("[TEST] Your deferred offer to study #{application_choice.course.name_and_code} has been changed")
      expect(email.to).to include(application_choice.application_form.candidate.email_address)

      expect(email.body.raw_source).to include('If the offer is still suitable for you, you need to meet the following')
    end
  end
end
