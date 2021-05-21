class ValidationError < ApplicationRecord
  enum service: {
    apply: 'apply',
    manage: 'manage',
  }

  validates :form_object, presence: true

  belongs_to :user, polymorphic: true, optional: true

  def self.list_of_distinct_errors_with_count
    distinct_errors = all.flat_map do |e|
      e.details.flat_map do |attribute, details|
        details['messages'].map do |message|
          [e.form_object, attribute, message]
        end
      end
    end

    distinct_errors
      .tally
      .sort_by { |_a, b| b }
      .reverse
  end

  def self.search(params)
    scope = includes('user')
    scope = scope.where(form_object: params[:form_object]) if params[:form_object]
    scope = scope.where(user_id: params[:user_id]) if params[:user_id]
    scope = scope.where(id: params[:id]) if params[:id]
    scope = scope.where('details->? IS NOT NULL', params[:attribute]) if params[:attribute]
    scope
  end
end
