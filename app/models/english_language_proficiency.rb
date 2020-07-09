class EnglishLanguageProficiency < ApplicationRecord
  belongs_to :application_form
  belongs_to :efl_qualification, polymorphic: true
end
