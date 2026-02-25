class GeneratePossiblePreviousTeacherTraining
  attr_reader :candidate
  def initialize(candidate)
    @candidate = candidate
  end

  def call
    return if data.blank?

    ActiveRecord::Base.transaction do
      candidate.possible_previous_teacher_trainings.destroy_all

      data.each do |possible_previous_teacher_training_data|
        next if previous_teacher_training_declared?(possible_previous_teacher_training_data)

        PossiblePreviousTeacherTraining.find_or_create_by!(
          candidate:,
          provider_name: possible_previous_teacher_training_data.accredited_provider_name,
          provider: accredited_provider(possible_previous_teacher_training_data.accredited_provider_code),
          started_on: possible_previous_teacher_training_data.trainee_start_date,
          ended_on: possible_previous_teacher_training_data.withdraw_date,
        )
      end
    end
  end

private

  def accredited_provider(code)
    Provider.find_by(code:)
  end

  def data
    @data = DfE::Bigquery::NonDisclosureTraineeWithdrawals.new(candidate:).trainee_data
  end

  def previous_teacher_training_declared?(possible_previous_teacher_training_data)
    raise possible_previous_teacher_training_data
    provider_record = accredited_provider(possible_previous_teacher_training_data.accredited_provider_code)
    started_at = possible_previous_teacher_training_data.trainee_start_date.to_time.beginning_of_month
    ended_at = possible_previous_teacher_training_data.withdraw_date.to_time.end_of_month
    previous_teacher_training_in_timeframe = candidate.previous_teacher_trainings.where(
      started_at: started_at..,
      ended_at: ..ended_at,
    )

    return false if previous_teacher_training_in_timeframe.blank?

    ((provider_record.present? && previous_teacher_training_in_timeframe.find_by(provider: provider_record)) ||
      previous_teacher_training_in_timeframe.find_by(
        provider_name: possible_previous_teacher_training_data.accredited_provider_name,
      )).present?
  end
end
