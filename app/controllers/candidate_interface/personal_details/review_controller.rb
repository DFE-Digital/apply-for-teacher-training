module CandidateInterface
  module PersonalDetails
    class ReviewController < SectionController
      def show
        @application_form = current_application

        # Personal information - First name, last name, Date of birth
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)

        # What is your nationality?
        @nationalities_form = NationalitiesForm.build_from_application(current_application)

        # Right to work or study in the UK
        @immigration_right_to_work_form = ImmigrationRightToWorkForm.build_from_application(current_application)

        # Visa or immigration status
        @immigration_status_form = ImmigrationStatusForm.build_from_application(current_application)

        @section_complete_form = SectionCompleteForm.new(
          completed: current_application.personal_details_completed,
        )

        @personal_details_review = PersonalDetailsReviewComponent.new(
          application_form: current_application,
          editable: @section_policy.can_edit?,
        )
      end

      def create
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
        @immigration_right_to_work_form = ImmigrationRightToWorkForm.build_from_application(current_application)
        @immigration_status_form = ImmigrationStatusForm.build_from_application(current_application)
        @section_complete_form = SectionCompleteForm.new(completed: application_form_params[:completed])

        @personal_details_review_form = PersonalDetailsReviewForm.new(
          personal_details_form: @personal_details_form,
          nationalities_form: @nationalities_form,
          immigration_right_to_work_form: @immigration_right_to_work_form,
          immigration_status_form: @immigration_status_form,
          current_application: current_application,
        )

        if @personal_details_review_form.valid?
          save_section_complete_form
        else
          @personal_details_review = PersonalDetailsReviewComponent.new(
            application_form: current_application,
            editable: @section_policy.can_edit?,
          )
          render :show
        end
      end

    private

      def save_section_complete_form
        if @section_complete_form.save(current_application, :personal_details_completed)
          redirect_to_candidate_root
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end
    end
  end
end

class PersonalDetailsReviewForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :current_application

  attribute :personal_details_form
  attribute :nationalities_form
  attribute :immigration_right_to_work_form
  attribute :immigration_status_form

  validate :all_sections_valid?

private

  def all_sections_valid?
    valid = personal_details_form.valid? && nationalities_form.valid? && right_to_work_valid?

    errors.add(:personal_details_form, personal_details_form.errors.full_messages) if personal_details_form.errors.any?
    errors.add(:nationalities_form, nationalities_form.errors.full_messages) if nationalities_form.errors.any?
    errors.add(:immigration_right_to_work_form, immigration_right_to_work_form.errors.full_messages) if immigration_right_to_work_form.errors.any?
    errors.add(:immigration_status_form, immigration_status_form.errors.full_messages) if immigration_status_form.errors.any?

    valid
  end

  def right_to_work_valid?
    return true if current_application.british_or_irish?

    immigration_right_to_work_form.valid? && immigration_status_form.valid?
  end
end
