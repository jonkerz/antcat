# frozen_string_literal: true

class RemoveReasonMissingFromReferences < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :references, :reason_missing, :string
    end
  end
end
