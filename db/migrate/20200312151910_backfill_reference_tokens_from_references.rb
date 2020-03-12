class BackfillReferenceTokensFromReferences < ActiveRecord::Migration[6.0]
  def change
    references = ApplicationReference.where.not(hashed_sign_in_token: nil)

    references.each do |reference|
      ReferenceToken.create!(
        application_reference: reference,
        hashed_token: reference.hashed_sign_in_token,
      )
    end
  end
end
