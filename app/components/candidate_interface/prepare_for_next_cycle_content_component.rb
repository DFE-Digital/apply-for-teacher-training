module CandidateInterface
  class PrepareForNextCycleContentComponent < ApplicationComponent
    delegate :recruitment_cycle_timetable, to: :application_form
    delegate :after_find_opens?, :before_apply_opens?, :academic_year_range_name, to: :next_recruitment_cycle
    delegate :previous_application_form, to: :application_form

    attr_reader :application_form, :application_form_presenter

    def initialize(application_form:)
      @application_form = application_form
      @application_form_presenter = ApplicationFormPresenter.new(application_form)
    end

    def next_recruitment_cycle
      @next_recruitment_cycle ||= if application_form.after_apply_deadline?
                                    recruitment_cycle_timetable.relative_next_timetable
                                  else
                                    recruitment_cycle_timetable
                                  end
    end

    def find_opens
      next_recruitment_cycle.find_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def apply_opens
      next_recruitment_cycle.apply_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def show_button?
      after_find_opens? && !next_recruitment_cycle.after_apply_deadline? &&
        application_form.can_submit_more_choices?
    end

    def list_of_links
      [
        visa_information_link,
        govuk_link_to('confirm your contact information', path_to_contact_details),
        qualifications_link,
        efl_link,
        govuk_link_to(
          'enter or confirm your equality and diversity information',
          candidate_interface_start_equality_and_diversity_path,
        ),
        previous_itt_link,
        govuk_link_to(
          'confirm your references are up to date',
          candidate_interface_references_review_path,
        ),
      ].compact
    end

  private

    def visa_information_link
      if application_form.immigration_status.nil? && !application_form.british_or_irish?
        govuk_link_to('enter or confirm your visa information', path_to_personal_information)
      end
    end

    def qualifications_link
      if application_form.application_qualifications.non_uk_gcses.any? do |gcse|
        DfE::ReferenceData::International::Qualifications::QUALIFICATIONS.all_as_hash.values.filter do |option|
          option.countries.include?(gcse.institution_country) && option.subjects.include?(gcse.subject)
        end
      end

        govuk_link_to('confirm your qualifications are up to date', candidate_interface_details_path)
      end
    end

    def efl_link
      if previous_application_form&.efl_completed
        govuk_link_to(
          'enter or confirm your English language skills',
          application_form_presenter.english_as_a_foreign_language_path,
        )
      end
    end

    def previous_itt_link
      if previous_application_form&.published_previous_teacher_trainings&.one?
        govuk_link_to(
          'confirm whether you have started teacher training in the past',
          application_form_presenter.path_to_previous_teacher_training,
        )
      end
    end

    def path_to_contact_details
      application_form_presenter.contact_details_valid? ? candidate_interface_contact_information_review_path : candidate_interface_new_phone_number_path
    end

    def path_to_personal_information
      all_sections_completed = application_form.first_name.present? &&
                               application_form.first_nationality.present? &&
                               (!application_form.english_main_language.nil? || application_form.right_to_work_or_study_present?)
      all_sections_completed ? candidate_interface_personal_details_show_path : candidate_interface_name_and_dob_path
    end
  end
end
