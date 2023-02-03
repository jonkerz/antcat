# frozen_string_literal: true

require 'rails_helper'

feature "Editing journals" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
    create :journal, name: "Psyche"
    i_go_to 'the references page'
    i_follow "Journals"
    i_follow "Psyche"
  end

  scenario "Edit a journal's name (with feed)" do
    i_follow "Edit journal name"
    fill_in "journal_name", with: "Science"
    click_button "Save"
    i_should_see "Successfully updated journal"

    i_go_to 'the references page'
    i_follow "Journals"
    i_should_see "Science"

    there_should_be_an_activity "Archibald edited the journal Science \\(changed journal name from Psyche\\)"
  end
end