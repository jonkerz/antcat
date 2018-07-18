require 'spec_helper'

describe UserDecorator do
  let(:user) { build_stubbed :user, name: "First Last", email: "email@example.com" }

  describe "#user_page_link" do
    it "link the name to the user page" do
      expect(user.decorate.user_page_link).
        to eq %(<a href="/users/#{user.id}">First Last</a>)
    end
  end

  describe "#ping_user_link" do
    it "like `#user_page_link`, but prefixed with an '@'" do
      expect(user.decorate.ping_user_link).
        to eq %(<a href="/users/#{user.id}">@<strong>First Last</strong></a>)
    end
  end
end
