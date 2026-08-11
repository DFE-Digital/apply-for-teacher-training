module CandidateInterface
  class CarryOverTaskListComponent < ApplicationComponent
    Section = Data.define(:name, :link)
    delegate :previous_application_form, to: :application_form

    attr_reader :application_form, :application_form_presenter

    def initialize(application_form:)
      @application_form = application_form
      @application_form_presenter = ApplicationFormPresenter.new(application_form)
    end

    def render?
      carry_over_list? || incomplete_details_message.present?
    end

    def list_of_links
      @list_of_links ||= [
        visa_information_link,
        contact_information_link,
        qualifications_link,
        efl_link,
        diversity_link,
        previous_itt_link,
        references_link,
      ].compact
    end

    def incomplete_details_message
      return unless additional_sections_incomplete?

      translation = if carry_over_list?
                      'mid_cycle_content_component.incomplete_details_with_carry_over_message'
                    else
                      'mid_cycle_content_component.incomplete_details_message'
                    end

      link = govuk_link_to('your details', candidate_interface_details_path)
      t(translation, link:).html_safe
    end

    def carry_over_list?
      application_form.previous_application_form.present? && list_of_links.any?
    end

  private

    def additional_sections_incomplete?
      if carry_over_list?
        (application_form_presenter.incomplete_sections.map(&:name) - list_of_links.map(&:name)).any?
      else
        application_form_presenter.incomplete_sections.any?
      end
    end

    def visa_information_link
      if (application_form.immigration_status.nil? || !application_form.visa_expiry_valid?) &&
         !application_form.british_or_irish? &&
         !application_form.personal_details_completed
        Section.new(
          name: :personal_details,
          link: govuk_link_to('enter or confirm your visa information', path_to_personal_information),
        )
      end
    end

    def contact_information_link
      if !application_form.contact_details_completed
        Section.new(
          name: :contact_details,
          link: govuk_link_to('confirm your contact information', path_to_contact_details),
        )
      end
    end

    def qualifications_link
      if application_form_presenter.incomplete_qualifications.any?
        qualification = application_form_presenter.incomplete_qualifications.first.name

        Section.new(
          name: qualification,
          link: govuk_link_to(
            'confirm your qualifications are up to date',
            path_to_qualifications(qualification),
          ),
        )
      end
    end

    def efl_link
      if !application_form.efl_completed
        Section.new(
          name: :efl,
          link: govuk_link_to(
            'enter or confirm your English language skills',
            application_form_presenter.english_as_a_foreign_language_path,
          ),
        )
      end
    end

    def diversity_link
      if !application_form.equality_and_diversity_completed
        Section.new(
          name: :equality_and_diversity,
          link: govuk_link_to(
            'enter or confirm your equality and diversity information',
            candidate_interface_start_equality_and_diversity_path,
          ),
        )
      end
    end

    def previous_itt_link
      if !application_form.previous_teacher_training_completed
        Section.new(
          name: :previous_teacher_training,
          link: govuk_link_to(
            'confirm whether you have started teacher training in the past',
            application_form_presenter.path_to_previous_teacher_training,
          ),
        )
      end
    end

    def references_link
      if !application_form.references_completed
        Section.new(
          name: :references_selected,
          link: govuk_link_to(
            'confirm your references are up to date',
            candidate_interface_references_review_path,
          ),
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

    def path_to_qualifications(qualification)
      case qualification
      when :english_gcse
        application_form_presenter.path_to_english_gcse
      when :maths_gcse
        application_form_presenter.path_to_math_gcse
      when :science_gcse
        application_form_presenter.path_to_science_gcse
      when :other_qualifications
        application_form_presenter.other_qualification_path
      when :degrees
        application_form_presenter.degrees_path
      end
    end
  end
end
