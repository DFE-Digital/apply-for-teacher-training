require 'rails_helper'

RSpec.describe Pool::Candidates do
  describe '.application_forms_for_provider' do
    context 'tests base query without filters' do
      it 'returns application_forms that should be on candidate pool list' do
        providers = [create(:provider)]

        rejected_candidate = create(:candidate)
        create(:candidate_preference, candidate: rejected_candidate)
        rejected_candidate_form = create(:application_form, :completed, candidate: rejected_candidate)
        create(:application_choice, :rejected, application_form: rejected_candidate_form)

        declined_candidate = create(:candidate)
        create(:candidate_preference, candidate: declined_candidate)
        declined_candidate_form = create(:application_form, :completed, candidate: declined_candidate)
        create(:application_choice, :declined, application_form: declined_candidate_form)

        withdrawn_candidate = create(:candidate)
        create(:candidate_preference, candidate: withdrawn_candidate)
        withdrawn_candidate_form = create(:application_form, :completed, candidate: withdrawn_candidate)
        create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)

        conditions_not_met_candidate = create(:candidate)
        create(:candidate_preference, candidate: conditions_not_met_candidate)
        conditions_not_met_candidate_form = create(:application_form, :completed, candidate: conditions_not_met_candidate)
        create(:application_choice, :conditions_not_met, application_form: conditions_not_met_candidate_form)

        offer_withdrawn_candidate = create(:candidate)
        create(:candidate_preference, candidate: offer_withdrawn_candidate)
        offer_withdrawn_candidate_form = create(:application_form, :completed, candidate: offer_withdrawn_candidate)
        create(:application_choice, :offer_withdrawn, application_form: offer_withdrawn_candidate_form)

        inactive_candidate = create(:candidate)
        create(:candidate_preference, candidate: inactive_candidate)
        inactive_candidate_form = create(:application_form, :completed, candidate: inactive_candidate)
        create(:application_choice, :inactive, application_form: inactive_candidate_form)

        application_forms = described_class.application_forms_for_provider(providers:, filters: {})

        expect(application_forms).to contain_exactly(
          rejected_candidate_form,
          declined_candidate_form,
          withdrawn_candidate_form,
          conditions_not_met_candidate_form,
          offer_withdrawn_candidate_form,
          inactive_candidate_form,
        )
      end

      it 'does not returns application_forms that should not be on the candidate pool list' do
        provider = create(:provider)
        providers = [provider]

        previous_year_form = create(:application_form, :completed, recruitment_cycle_year: previous_year)
        create(:candidate_preference, candidate: previous_year_form.candidate)
        create(:application_choice, :rejected, application_form: previous_year_form)

        opt_out_candidate = create(:candidate)
        create(:candidate_preference, pool_status: 'opt_out', candidate: opt_out_candidate)
        opt_out_candidate_form = create(:application_form, :completed, candidate: opt_out_candidate)
        create(:application_choice, :rejected, application_form: opt_out_candidate_form)

        dismissed_candidate = create(:candidate)
        create(:candidate_preference, candidate: dismissed_candidate)
        dismissed_candidate_form = create(:application_form, :completed, candidate: dismissed_candidate)
        create(:application_choice, :rejected, application_form: dismissed_candidate_form)
        create(:pool_dismissal, provider:, candidate: dismissed_candidate)

        rejected_candidate = create(:candidate)
        create(:candidate_preference, candidate: rejected_candidate)
        rejected_candidate_form = create(:application_form, :completed, candidate: rejected_candidate)
        create(:application_choice, :rejected, application_form: rejected_candidate_form)
        create(:application_choice, :awaiting_provider_decision, application_form: rejected_candidate_form)

        declined_candidate = create(:candidate)
        create(:candidate_preference, candidate: declined_candidate)
        declined_candidate_form = create(:application_form, :completed, candidate: declined_candidate)
        create(:application_choice, :declined, application_form: declined_candidate_form)
        create(:application_choice, :interviewing, application_form: declined_candidate_form)

        withdrawn_candidate = create(:candidate)
        create(:candidate_preference, candidate: withdrawn_candidate)
        withdrawn_candidate_form = create(:application_form, :completed, candidate: withdrawn_candidate)
        create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)
        create(:application_choice, :offer, application_form: withdrawn_candidate_form)

        conditions_not_met_candidate = create(:candidate)
        create(:candidate_preference, candidate: conditions_not_met_candidate)
        conditions_not_met_candidate_form = create(:application_form, :completed, candidate: conditions_not_met_candidate)
        create(:application_choice, :conditions_not_met, application_form: conditions_not_met_candidate_form)
        create(:application_choice, :pending_conditions, application_form: conditions_not_met_candidate_form)

        offer_withdrawn_candidate = create(:candidate)
        create(:candidate_preference, candidate: offer_withdrawn_candidate)
        offer_withdrawn_candidate_form = create(:application_form, :completed, candidate: offer_withdrawn_candidate)
        create(:application_choice, :offer_withdrawn, application_form: offer_withdrawn_candidate_form)
        create(:application_choice, :recruited, application_form: offer_withdrawn_candidate_form)

        inactive_candidate = create(:candidate)
        create(:candidate_preference, candidate: inactive_candidate)
        inactive_candidate_form = create(:application_form, :completed, candidate: inactive_candidate)
        create(:application_choice, :inactive, application_form: inactive_candidate_form)
        create(:application_choice, :offer_deferred, application_form: inactive_candidate_form)

        candidate_with_too_many_choices = create(:candidate)
        create(:candidate_preference, candidate: candidate_with_too_many_choices)
        candidate_with_too_many_choices_form = create(:application_form, :completed, candidate: candidate_with_too_many_choices)
        create_list(:application_choice, 15, :offer_withdrawn, application_form: candidate_with_too_many_choices_form)

        application_forms = described_class.application_forms_for_provider(providers:, filters: {})

        expect(application_forms).to be_empty
      end
    end

    context 'with filters' do
      it 'returns application_forms based on filters' do
        manchester_coordinates = [53.4807593, -2.2426305]
        liverpool_coordinates = [53.4076650, -2.9781493]

        provider = create(:provider)
        course = create(:course, provider:)
        tda_course = create(
          :course,
          provider:,
          program_type: :teacher_degree_apprenticeship,
        )
        course_option = create(
          :course_option,
          course: course,
        )
        part_time_course_option = create(
          :course_option,
          course: course,
          study_mode: :part_time,
        )
        part_time_tda_course_option = create(
          :course_option,
          course: tda_course,
          study_mode: :part_time,
        )

        subject = create(:subject)
        create(:course_subject, subject:, course:)
        create(:course_subject, subject:, course: tda_course)

        manchester_candidate_form = create_manchester_candidate_form(provider)
        subject_candidate_form = create_subject_candidate_form(course_option)
        part_time_candidate_form = create_part_time_candidate_form(part_time_course_option)
        undergraduate_candidate_form = create_undergraduate_candidate_form(part_time_tda_course_option)
        visa_sponsorship_candidate_form = create_visa_sponsorship_candidate_form(part_time_tda_course_option)

        filters = { origin: manchester_coordinates }
        application_forms = described_class.application_forms_for_provider(providers: [provider], filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          manchester_candidate_form.id,
          subject_candidate_form.id,
          part_time_candidate_form.id,
          undergraduate_candidate_form.id,
        )

        filters = { origin: manchester_coordinates, subject: [subject.id.to_s] }

        application_forms = described_class.application_forms_for_provider(providers: [provider], filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          part_time_candidate_form.id,
          subject_candidate_form.id,
          undergraduate_candidate_form.id,
        )

        filters = {
          origin: manchester_coordinates,
          subject: [subject.id.to_s],
          study_mode: ['part_time'],
        }

        application_forms = described_class.application_forms_for_provider(providers: [provider], filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          part_time_candidate_form.id,
          undergraduate_candidate_form.id,
        )

        filters = {
          origin: manchester_coordinates,
          subject: [subject.id.to_s],
          study_mode: ['part_time'],
          course_type: ['TDA'],
        }

        application_forms = described_class.application_forms_for_provider(providers: [provider], filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          undergraduate_candidate_form.id,
        )

        filters = {
          origin: liverpool_coordinates,
          subject: [subject.id.to_s],
          study_mode: ['part_time'],
          course_type: ['TDA'],
          visa_sponsorship: ['required'],
        }

        application_forms = described_class.application_forms_for_provider(providers: [provider], filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          visa_sponsorship_candidate_form.id,
        )
      end
    end

    def create_manchester_candidate_form(provider)
      manchester_candidate = create(:candidate)
      candidate_preference = create(:candidate_preference, candidate: manchester_candidate)
      create(:candidate_location_preference, :manchester, candidate_preference:)
      manchester_candidate_form = create(:application_form, :completed, candidate: manchester_candidate)
      course = create(:course, provider:)
      course_option = create(
        :course_option,
        course: course,
      )
      create(:application_choice, :rejected, application_form: manchester_candidate_form, course_option:)

      manchester_candidate_form
    end

    def create_subject_candidate_form(course_option)
      # This candidate also doesn't have a location preference.
      # They should still appear when searching by location
      subject_candidate = create(:candidate)
      _candidate_preference = create(:candidate_preference, candidate: subject_candidate)
      subject_candidate_form = create(:application_form, :completed, candidate: subject_candidate)
      create(:application_choice, :rejected, application_form: subject_candidate_form, course_option:)

      subject_candidate_form
    end

    def create_part_time_candidate_form(course_option)
      part_time_candidate = create(:candidate)
      candidate_preference = create(:candidate_preference, candidate: part_time_candidate)
      create(:candidate_location_preference, :manchester, candidate_preference:)
      part_time_candidate_form = create(:application_form, :completed, candidate: part_time_candidate)
      create(:application_choice, :rejected, application_form: part_time_candidate_form, course_option:)
      part_time_candidate_form
    end

    def create_undergraduate_candidate_form(course_option)
      undergraduate_candidate = create(:candidate)
      candidate_preference = create(:candidate_preference, candidate: undergraduate_candidate)
      create(:candidate_location_preference, :manchester, candidate_preference:)
      undergraduate_candidate_form = create(
        :application_form,
        :completed,
        candidate: undergraduate_candidate,
      )
      create(:application_choice, :declined, application_form: undergraduate_candidate_form, course_option:)
      undergraduate_candidate_form
    end

    def create_visa_sponsorship_candidate_form(course_option)
      visa_sponsorship_candidate = create(:candidate)
      candidate_preference = create(:candidate_preference, candidate: visa_sponsorship_candidate)
      create(:candidate_location_preference, :liverpool, candidate_preference:)
      visa_sponsorship_candidate_form = create(
        :application_form,
        :completed,
        candidate: visa_sponsorship_candidate,
        right_to_work_or_study: :no,
      )
      create(:application_choice, :declined, application_form: visa_sponsorship_candidate_form, course_option:)

      visa_sponsorship_candidate_form
    end
  end

  describe '.application_forms_in_the_pool' do
    it 'returns application_forms that should be in the candidate pool' do
      rejected_candidate = create(:candidate)
      rejected_candidate_form = create(:application_form, :completed, candidate: rejected_candidate)
      create(:candidate_preference, candidate: rejected_candidate)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)

      results = described_class.application_forms_in_the_pool

      expect(results).to contain_exactly(rejected_candidate_form)
    end
  end

  describe '.application_forms_eligible_for_pool' do
    it 'returns application_forms that should be in the candidate pool' do
      rejected_candidate_form = create(:application_form, :completed)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)
      _accepted_application_form = create(:application_form, :with_accepted_offer)

      results = described_class.application_forms_eligible_for_pool

      expect(results).to contain_exactly(rejected_candidate_form)
    end
  end
end
