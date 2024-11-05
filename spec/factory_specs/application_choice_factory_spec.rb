require 'rails_helper'

RSpec.describe 'ApplicationChoice factory' do
  subject(:record) { |attrs: {}| create(factory, *traits, **attributes, **attrs) }

  let(:factory) { :application_choice }
  let(:traits) { [] }
  let(:attributes) { {} }

  shared_examples 'an application_choice-derived factory' do
    it { is_expected.to be_valid }

    it 'creates 1 application choice' do
      expect { record }.to change(ApplicationChoice, :count).by(1)
    end

    it 'creates 1 application form' do
      expect { record }.to change(ApplicationForm, :count).by(1)
    end

    it 'creates 1 provider' do
      expect { record }.to change(Provider, :count).by(1)
    end

    it 'creates 1 site' do
      expect { record }.to change(Site, :count).by(1)
    end

    it 'creates 1 course_option' do
      expect { record }.to change(CourseOption, :count).by(1)
    end

    context 'if a recruitment year is set on a provided form' do
      let(:attributes) do
        {
          application_form: build(:application_form, recruitment_cycle_year: 2020),
        }
      end

      it 'creates the course with the same recruitment year' do
        expect(record.course_option.course.recruitment_cycle_year).to eq(2020)
      end
    end

    shared_examples 'post-build setup' do
      it 'sets the `current_course_option` if one is not provided' do
        expect(record.current_course_option).to be_present
        expect(record.current_course_option).to eq(record.course_option)
      end

      context 'if a `current_course_option` is provided' do
        let(:course_option) { create(:course_option) }
        let(:attributes) do
          { current_course_option: course_option }
        end

        it 'does not overwrite the `current_course_option`' do
          expect(record.current_course_option).to eq(course_option)
        end
      end

      it 'sets the `original_course_option` if one is not provided' do
        expect(record.original_course_option).to be_present
        expect(record.original_course_option).to eq(record.course_option)
      end

      context 'if an `original_course_option` is provided' do
        let(:course_option) { create(:course_option) }
        let(:attributes) do
          { original_course_option: course_option }
        end

        it 'does not overwrite the `original_course_option`' do
          expect(record.original_course_option).to eq(course_option)
        end
      end

      it 'sets the `current_recruitment_cycle_year` if one is not provided' do
        expect(record.current_recruitment_cycle_year).to be_present
        expect(record.current_recruitment_cycle_year).to eq(record.course_option.course.recruitment_cycle_year)
      end

      context 'if a `current_recruitment_cycle_year` is provided' do
        let(:attributes) do
          { current_recruitment_cycle_year: 2020 }
        end

        field :current_recruitment_cycle_year, value: 2020
      end
    end

    context 'when stubbing' do
      subject(:record) { build_stubbed(factory, *traits, **attributes) }

      include_examples 'post-build setup'
    end

    context 'when building' do
      subject(:record) { build(factory, *traits, **attributes) }

      include_examples 'post-build setup'
    end
  end

  factory :application_choice do
    include_examples 'an application_choice-derived factory'

    context 'if a submitted form is provided' do
      let(:attributes) do
        {
          application_form: build(:application_form, :submitted),
        }
      end

      field :status, one_of: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map(&:to_s)
    end

    context 'if an unsubmitted form is provided' do
      let(:attributes) do
        {
          application_form: build(:application_form, submitted_at: nil),
        }
      end

      field :status, value: 'unsubmitted'

      context 'but a submitted status is given' do
        let(:attributes) do
          {
            application_form: build(:application_form, submitted_at: nil),
            status: 'awaiting_provider_decision',
          }
        end

        it 'sets `sent_to_provider_at` to some time after `created_at`' do
          expect(record.sent_to_provider_at).to be > record.created_at
        end
      end
    end

    context 'if a course is provided' do
      let(:course) { create(:course, :with_course_options) }
      let(:attributes) do
        { course: }
      end

      it 'uses the provided course' do
        expect(record.course_option.course).to eq(course)
      end
    end

    context 'if a `withdrawn` status is given' do
      let(:attributes) do
        { status: 'withdrawn' }
      end

      it 'sets `withdrawn_at` to some time after `sent_to_provider_at`' do
        expect(record.withdrawn_at).to be > record.sent_to_provider_at
      end
    end
  end

  trait :previous_year do
    it { is_expected.to be_valid }

    it 'associates a course option from the previous recruitment cycle' do
      expect(record.course_option.course.recruitment_cycle_year).to eq(RecruitmentCycle.previous_year)
    end

    it 'associates a form from the previous recruitment cycle' do
      expect(record.application_form.recruitment_cycle_year).to eq(RecruitmentCycle.previous_year)
    end
  end

  trait :previous_year_but_still_available do
    it_behaves_like 'trait :previous_year'

    it 'creates a new course option for the same course as the previous year' do
      expect { record }.to change { CourseOption.count }.by(2)
      expect(CourseOption.count).to eq(2)

      previous_year = CourseOption.first
      expect(previous_year.course.recruitment_cycle_year).to eq(RecruitmentCycle.previous_year)
      expect(record.course_option).to eq(previous_year)

      current_year = CourseOption.last
      expect(current_year.course.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
      expect(current_year.site.code).to eq(previous_year.site.code)
    end
  end

  trait :with_course_uuid do
    it 'associates a course that has a UUID' do
      expect(record.course_option.course.uuid).to be_present
    end
  end

  shared_examples 'it has a completed application form' do
    it 'associates a valid completed application form' do
      # Valid
      expect(record.application_form).to be_valid

      # Completed
      expect(record.application_form).to be_submitted
      expect(record.application_form.course_choices_completed).to be(true)
      expect(record.application_form.safeguarding_issues_completed).to be_present
    end
  end

  trait :with_completed_application_form do
    it { is_expected.to be_valid }

    it_behaves_like 'it has a completed application form'

    it 'associates an application form with a degree and GCSEs' do
      # With degree
      expect(record.application_form.application_qualifications.degrees).to be_present

      # With GCSEs
      expect(record.application_form.application_qualifications.gcses).to be_present
    end
  end

  trait :unsubmitted do
    it { is_expected.to be_valid }
    it { is_expected.to be_unsubmitted }
  end

  trait :application_not_sent do
    it { is_expected.to be_valid }
    it { is_expected.to be_application_not_sent }

    it 'sets `rejected_at` to some time after `created_at`' do
      expect(record.rejected_at).to be > record.created_at
    end

    field :rejection_reason, type: String
  end

  shared_examples 'it has an offer' do
    it { is_expected.to be_valid }

    it_behaves_like 'it has a completed application form'

    it 'creates an offer' do
      expect { record }.to change(Offer, :count).by(1)
    end

    field :offer, presence: true

    it "sets the `created_at` timestamp to 1 second after the form's `created_at`" do
      expect(record.created_at).to eq(record.application_form.created_at + 1.second)
    end

    it 'sets the `sent_to_provider_at` timestamp to 1 second after `created_at`' do
      expect(record.sent_to_provider_at).to eq(record.created_at + 1.second)
    end

    it 'sets the `offered_at` timestamp to 1 second after `sent_to_provider_at`' do
      expect(record.offered_at).to eq(record.sent_to_provider_at + 1.second)
    end
  end

  trait :offered do
    it { is_expected.to be_offer }

    include_examples 'it has an offer'

    it_behaves_like 'an application_choice-derived factory'
  end

  trait :course_changed do
    context 'if a course option is provided that has other courses with the same provider and the same accredited provider, in the same cycle year' do
      let(:original_course) { create(:course, :with_accredited_provider, :with_course_options) }
      let(:new_course) do
        create(:course, :with_course_options,
               provider: original_course.provider,
               accredited_provider: original_course.accredited_provider,
               recruitment_cycle_year: original_course.recruitment_cycle_year)
      end

      let(:attributes) do
        { course_option: original_course.course_options.first }
      end

      it "sets the `current_course_option` to one of the other courses's options" do
        expect(new_course.course_options).to include(record.current_course_option)
      end
    end
  end

  trait :course_changed_before_offer do
    it_behaves_like 'trait :course_changed'
    it { is_expected.to be_offer }

    it_behaves_like 'it has an offer'
  end

  trait :course_changed_after_offer do
    it_behaves_like 'trait :course_changed'
    it { is_expected.to be_offer }

    it_behaves_like 'it has an offer'

    field :course_changed_at, presence: false

    it 'sets `offer_changed_at` to 1 second after `offered_at`' do
      expect(record.offer_changed_at).to eq(record.offered_at + 1.second)
    end
  end

  shared_examples 'it is accepted' do
    it_behaves_like 'it has an offer'

    it 'sets the `accepted_at` timestamp to 1 second after `offered_at`' do
      expect(record.accepted_at).to eq(record.offered_at + 1.second)
    end
  end

  trait :accepted do
    it { is_expected.to be_pending_conditions }

    include_examples 'it is accepted'
  end

  trait :pending_conditions, aliased_to: :accepted

  trait :recruited do
    it_behaves_like 'it is accepted'

    it { is_expected.to be_recruited }

    it 'sets the `recruited_at` timestamp to 1 second after `accepted_at`' do
      expect(record.recruited_at).to eq(record.accepted_at + 1.second)
    end
  end

  shared_examples 'RBD has been set' do
    field :reject_by_default_days, presence: true

    it 'sets `reject_by_default_at` to `reject_by_default_days` business days from now' do
      expect(record.reject_by_default_at).to be_within(1.second).of(record.reject_by_default_days.business_days.from_now)
    end
  end

  trait :awaiting_provider_decision do
    it { is_expected.to be_awaiting_provider_decision }

    include_examples 'RBD has been set'
  end

  trait :interviewing do
    it { is_expected.to be_interviewing }

    it_behaves_like 'RBD has been set'

    field :interviews, presence: true
  end

  trait :with_cancelled_interview do
    it { is_expected.to be_awaiting_provider_decision }

    it_behaves_like 'RBD has been set'

    it "ensures there's at least one cancelled interview" do
      expect(record.interviews).to be_present
      expect(record.interviews.first).to be_cancelled
    end
  end

  shared_examples 'it is withdrawn' do
    it { is_expected.to be_withdrawn }

    it 'associates a submitted form' do
      expect(record.application_form).to be_submitted
    end

    field :withdrawn_at, presence: true
  end

  trait :withdrawn do
    include_examples 'it is withdrawn'

    field :withdrawn_or_declined_for_candidate_by_provider, value: false
  end

  trait :withdrawn_at_candidates_request do
    it_behaves_like 'it is withdrawn'

    field :withdrawn_or_declined_for_candidate_by_provider, value: true
  end

  trait :withdrawn_with_survey_completed do
    it_behaves_like 'trait :withdrawn'

    field :withdrawal_feedback, presence: true
  end

  trait :offer_deferred do
    it_behaves_like 'it is accepted'

    it { is_expected.to be_offer_deferred }

    it 'sets `offer_deferred_at` to after `accepted_at`' do
      expect(record.offer_deferred_at).to be > record.accepted_at
    end

    field :status_before_deferral, value: 'pending_conditions'
  end

  trait :offer_deferred_after_recruitment do
    it_behaves_like 'it is accepted'

    it 'sets the `recruited_at` timestamp to after `accepted_at`' do
      expect(record.recruited_at).to be > record.accepted_at
    end

    it { is_expected.to be_offer_deferred }

    it 'sets `offer_deferred_at` to after `recruited_at`' do
      expect(record.offer_deferred_at).to be > record.recruited_at
    end

    field :status_before_deferral, value: 'recruited'
  end

  trait :offer_withdrawn do
    it_behaves_like 'it has an offer'

    it { is_expected.to be_offer_withdrawn }

    it 'sets `offer_withdrawn_at` to after `offered_at`' do
      expect(record.offer_withdrawn_at).to be > record.offered_at
    end

    field :offer_withdrawal_reason, type: String
  end

  trait :conditions_not_met do
    it_behaves_like 'an application_choice-derived factory'
    it_behaves_like 'it is accepted'

    it { is_expected.to be_conditions_not_met }

    it 'sets `conditions_not_met_at` to after `accepted_at`' do
      expect(record.conditions_not_met_at).to be > record.accepted_at
    end

    it 'marks all conditions as unmet' do
      expect(record.offer.conditions).to be_all(&:unmet?)
    end
  end

  trait :declined do
    it_behaves_like 'it has an offer'

    it { is_expected.to be_declined }

    it 'sets `declined_at` to after `offered_at`' do
      expect(record.declined_at).to be > record.offered_at
    end

    field :withdrawn_or_declined_for_candidate_by_provider, value: false
  end

  trait :declined_by_default do
    it_behaves_like 'trait :declined'

    field :declined_by_default?, value: true
  end

  shared_examples 'it is rejected' do
    it { is_expected.to be_rejected }

    it 'associates a submitted form' do
      expect(record.application_form).to be_submitted
    end

    it 'sets `rejected_at` to after `sent_to_provider_at`' do
      expect(record.rejected_at).to be > record.sent_to_provider_at
    end
  end

  trait :rejected do
    include_examples 'it is rejected'

    field :rejection_reason, type: String
    field :rejection_reasons_type, value: 'rejection_reason'
  end

  trait :rejected_by_default do
    include_examples 'it is rejected'

    field :rejected_by_default, value: true
    field :rejection_reason, presence: false
    field :rejection_reasons_type, presence: false
  end

  trait :rejected_by_default_with_feedback do
    include_examples 'it is rejected'

    field :rejected_by_default, value: true
    field :rejection_reason, type: String
    field :rejection_reasons_type, value: 'rejection_reason'

    it 'sets `reject_by_default_feedback_sent_at` to after `rejected_at`' do
      expect(record.reject_by_default_feedback_sent_at).to be > record.rejected_at
    end

    it 'creates an audit entry' do
      expect { record }.to change { Audited::Audit.count }.by(1)
      expect(Audited::Audit.last.associated).to eq(record.application_form)
    end
  end

  trait :with_old_structured_rejection_reasons do
    include_examples 'it is rejected'

    field :rejection_reasons_type, value: 'reasons_for_rejection'

    it 'sets the old-style structured rejection reasons' do
      expect(record.structured_rejection_reasons['candidate_behaviour_y_n']).to eq('Yes')
      expect(record.structured_rejection_reasons['safeguarding_y_n']).to eq('Yes')
    end

    it 'creates an audit entry' do
      expect { record }.to change { Audited::Audit.count }.by(2)
      expect(Audited::Audit.last.associated).to eq(record.application_form)
    end
  end

  trait :with_structured_rejection_reasons do
    include_examples 'it is rejected'

    field :rejection_reasons_type, value: 'rejection_reasons'

    it 'sets the structured rejection reasons' do
      expect(record.structured_rejection_reasons.dig('selected_reasons', 0, 'id')).to eq('qualifications')
      expect(record.structured_rejection_reasons.dig('selected_reasons', 0, 'label')).to eq('Qualifications')
    end

    it 'creates an audit entry' do
      expect { record }.to change { Audited::Audit.count }.by(2)
      expect(Audited::Audit.last.associated).to eq(record.application_form)
    end
  end

  trait :with_vendor_api_rejection_reasons do
    include_examples 'it is rejected'

    field :rejection_reasons_type, value: 'vendor_api_rejection_reasons'

    it 'sets the structured rejection reasons' do
      expect(record.structured_rejection_reasons.dig('selected_reasons', 0, 'id')).to eq('qualifications')
      expect(record.structured_rejection_reasons.dig('selected_reasons', 0, 'label')).to eq('Qualifications')
    end

    it 'creates an audit entry' do
      expect { record }.to change { Audited::Audit.count }.by(2)
      expect(Audited::Audit.last.associated).to eq(record.application_form)
    end
  end
end
