# frozen_string_literal: true

class AddDeletedToHistoryItems < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :history_items, :deleted, :boolean, default: false, null: false
    end
  end
end
