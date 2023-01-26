# frozen_string_literal: true

require 'rails_helper'

feature "Signing up" do
  scenario "Sign up (with feed)" do
    i_go_to 'the main page'
    i_follow "Sign up", within: 'the desktop menu'
    i_fill_in "user_email", with: "pizza@example.com"
    i_fill_in "user_name", with: "Quintus Batiatus"
    i_fill_in "user_password", with: "secret123"
    i_fill_in "user_password_confirmation", with: "secret123"
    i_press "Sign Up"
    i_should_be_on 'the main page'
    i_should_see "Welcome! You have signed up successfully."

    i_go_to 'the activity feed'
    i_should_see "Quintus Batiatus registered an account, welcome to antcat.org!", within: 'the activity feed'
  end
end
