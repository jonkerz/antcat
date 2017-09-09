require 'spec_helper'

describe Api::V1::AuthorNamesController do
  describe "GET index" do
    before do
      create :author_name, name: 'Bolton'
      create :author_name, name: 'Fisher'
      get :index
    end

    it "gets all author names keys" do
      expect(response.body.to_s).to include "Bolton"
      expect(response.body.to_s).to include "Fisher"
      author_names = JSON.parse response.body
      expect(author_names.count).to eq 2
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status 200
    end
  end

  describe "GET show" do
    let!(:author_name) { create :author_name, name: 'Bolton' }

    before { get :show, id: author_name.id }

    it "fetches an author name" do
      expect(response.body.to_s).to include "Bolton"
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status 200
    end
  end
end
