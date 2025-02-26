# Decorator for GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp model
class Adviser::TeacherTrainingAdviserSignUpDecorator < SimpleDelegator
  def attributes_as_snake_case
    to_hash.transform_keys do |key|
      __getobj__.class.attribute_map.invert[key]
    end
  end

  def adviser_status
    # Constants for Adviser Statuses
    status_id = try(:assignment_status_id)
    status = Adviser::Constants.fetch(:adviser_status).key(status_id)
    ApplicationForm.adviser_statuses[status || :unassigned]
  end
end
