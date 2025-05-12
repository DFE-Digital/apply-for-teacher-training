require 'rails_helper'

RSpec.describe DetectInvariantsDailyCheck do
  before do
    # or unwanted exceptions will be thrown by this check
    TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)

    create(
      :monthly_statistics_report,
      :v1,
      generation_date: MonthlyStatisticsTimetable.current_generation_date,
    )
  end

  describe '#perform' do
    it 'detects application choices for courses in the last cycle' do
      # Both of these are captured for this scenario
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::ApplicationHasCourseChoiceInPreviousCycle))
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::ApplicationWithADifferentCyclesCourse))

      this_year_course = create(:course_option)
      last_year_course = create(:course_option, :previous_year)

      bad_form_this_year = create(:completed_application_form, submitted_at: Time.zone.local(current_year, 10, 6, 9), recruitment_cycle_year: current_year)
      good_form_this_year = create(:completed_application_form, submitted_at: Time.zone.local(current_year, 10, 6, 9), recruitment_cycle_year: current_year)
      good_form_last_year = create(:application_form, submitted_at: 1.year.ago)

      create(:application_choice, application_form: bad_form_this_year, course_option: last_year_course)
      create(:application_choice, application_form: good_form_this_year, course_option: this_year_course)
      create(:application_choice, application_form: good_form_last_year, course_option: last_year_course)

      described_class.new.perform

      expect(Sentry).to have_received(:capture_exception).with(
        described_class::ApplicationHasCourseChoiceInPreviousCycle.new(
          <<~MSG,
            The following application forms have course choices from the previous recruitment cycle

            #{HostingEnvironment.application_url}/support/applications/#{bad_form_this_year.id}
          MSG
        ),
      )
    end

    it 'doesn’t alert when the course sync has succeeded recently' do
      allow(Sentry).to receive(:capture_exception)

      described_class.new.perform

      expect(Sentry).not_to have_received(:capture_exception)
    end

    it 'detects non-deferred application choices with a course from a different recruitment cycle' do
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::ApplicationWithADifferentCyclesCourse))

      application_form_with_invalid_course = create(:application_form)
      application_form_with_valid_course = create(:application_form)

      course_from_previous_cycle = create(:course, recruitment_cycle_year: previous_year)
      course_from_current_cycle = create(:course, recruitment_cycle_year: current_year)

      old_course_option = create(:course_option, course: course_from_previous_cycle)
      new_course_option = create(:course_option, course: course_from_current_cycle)

      create(:application_choice, course_option: old_course_option, application_form: application_form_with_invalid_course)
      create(:application_choice, current_course_option: new_course_option, application_form: application_form_with_valid_course)
      create(:application_choice, course_option: old_course_option, application_form: application_form_with_valid_course, offer_deferred_at: Time.zone.now)

      described_class.new.perform

      expect(Sentry).to have_received(:capture_exception).with(
        described_class::ApplicationWithADifferentCyclesCourse.new(
          <<~MSG,
            The following applications have an application choice with a course from a different recruitment cycle

            #{HostingEnvironment.application_url}/support/applications/#{application_form_with_invalid_course.id}
          MSG
        ),
      )
    end

    it 'detects submitted applications with more than the maximum number of course choices' do
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::SubmittedApplicationHasMoreThanTheMaxCourseChoices))

      good_application_form = create(:completed_application_form, submitted_application_choices_count: 4)
      good_application_form.application_choices << build_list(:application_choice, 6, :inactive)

      bad_application_form = create(:completed_application_form, submitted_application_choices_count: 3)
      bad_application_form.application_choices << build_list(:application_choice, 2, status: :offer)

      ApplicationChoice.all.each { |a| a.update_course_option_and_associated_fields! create(:course_option) }

      expect(good_application_form.reload.application_choices.count).to eq(10)
      expect(bad_application_form.reload.application_choices.count).to eq(5)

      described_class.new.perform

      expect(Sentry).to have_received(:capture_exception).once
      expect(Sentry).to have_received(:capture_exception).with(
        described_class::SubmittedApplicationHasMoreThanTheMaxCourseChoices.new(
          <<~MSG,
            The following application forms have been submitted with more than #{ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES.humanize} course choices

            #{HostingEnvironment.application_url}/support/applications/#{bad_application_form.id}
          MSG
        ),
      )
    end

    it 'detects submitted applications with more than the maximum number of unsuccessful course choices' do
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::SubmittedApplicationHasMoreThanTheMaxUnsuccessfulCourseChoices))
      total_number_of_possible_unsuccessful_applications =
        ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS +
        ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES - 1

      good_mix_of_rejected_and_inflight_form = create(:completed_application_form)
      good_mix_of_rejected_and_inflight_form.application_choices << build_list(:application_choice, total_number_of_possible_unsuccessful_applications, :rejected)
      good_mix_of_rejected_and_inflight_form.application_choices << build_list(:application_choice, ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES)

      bad_mix_of_rejected_and_inflight_form = create(:completed_application_form)
      bad_mix_of_rejected_and_inflight_form.application_choices << build_list(:application_choice, total_number_of_possible_unsuccessful_applications + 1, :rejected)
      bad_mix_of_rejected_and_inflight_form.application_choices << build_list(:application_choice, ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES)

      good_application_form = create(:completed_application_form)
      good_application_form.application_choices << build_list(:application_choice, total_number_of_possible_unsuccessful_applications, :rejected)

      bad_application_form = create(:completed_application_form)
      bad_application_form.application_choices << build_list(:application_choice, total_number_of_possible_unsuccessful_applications + 1, status: :rejected)

      ApplicationChoice.all.each { |a| a.update_course_option_and_associated_fields! create(:course_option) }

      described_class.new.perform

      expect(Sentry).to have_received(:capture_exception).once

      expect(Sentry).to have_received(:capture_exception).with(
        described_class::SubmittedApplicationHasMoreThanTheMaxUnsuccessfulCourseChoices.new(
          <<~MSG,
            The following application forms have been submitted with more than #{total_number_of_possible_unsuccessful_applications.humanize} unsuccessful course choices

            #{HostingEnvironment.application_url}/support/applications/#{bad_mix_of_rejected_and_inflight_form.id}
            #{HostingEnvironment.application_url}/support/applications/#{bad_application_form.id}
          MSG
        ),
      )
    end

    it 'detects application choices with out-of-date provider_ids' do
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::ApplicationChoicesWithOutOfDateProviderIds))

      choices = create_list(:application_choice, 3)
      empty_ids = choices.second
      empty_ids.update(provider_ids: [])
      wrong_ids = choices.third
      wrong_ids.update(provider_ids: [1024])

      accredited_course = create(:course, :with_accredited_provider)
      accredited_option = create(:course_option, course: accredited_course)
      reverse_ids = create(:application_choice, course_option: accredited_option)
      reverse_ids.update(provider_ids: reverse_ids.provider_ids.reverse)

      described_class.new.perform

      expected_ids = [empty_ids.id, wrong_ids.id].sort.join(', ')

      message = "Out-of-date application choices: #{expected_ids}" # reverse order ignored
      expect(Sentry).to have_received(:capture_exception)
                        .with(described_class::ApplicationChoicesWithOutOfDateProviderIds.new(message))
    end

    it 'detects obsolete feature flags' do
      allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::ObsoleteFeatureFlags))

      obsolete_features = create_list(:feature, 5)
      FeatureFlag::FEATURES.each { |feature| Feature.find_or_create_by(name: feature.first) }

      described_class.new.perform

      message = 'The following obsolete feature flags have yet to be deleted from the database: ' \
                "#{obsolete_features.map(&:name).sort.to_sentence}"

      expect(Sentry).to have_received(:capture_exception)
                    .with(described_class::ObsoleteFeatureFlags.new(message))
    end

    context 'when checking the monthly statistics report' do
      let(:message) { 'The monthly statistics report has not been generated for June' }
      let(:exception) { described_class::MonthlyStatisticsReportHasNotRun.new(message) }

      before do
        allow(HostingEnvironment).to receive(:production?).and_return true
        allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::MonthlyStatisticsReportHasNotRun))
      end

      context 'when it has been generated' do
        it 'does not send an alert' do
          travel_temporarily_to(Date.new(2023, 6, 26)) do
            create(
              :monthly_statistics_report,
              :v1,
              generation_date: Date.new(2023, 6, 19),
            )

            described_class.new.perform

            expect(Sentry).not_to have_received(:capture_exception).with(exception)
          end
        end
      end

      context 'when it has not been generated' do
        it 'sends an alert' do
          travel_temporarily_to(Date.new(2023, 6, 26)) do
            create(
              :monthly_statistics_report,
              :v1,
              generation_date: Date.new(2023, 5, 15),
            )

            described_class.new.perform

            expect(Sentry).to have_received(:capture_exception).with(exception)
          end
        end
      end
    end
  end
end
