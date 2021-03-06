# frozen_string_literal: true

require 'rails_helper'

describe Authors::AutocompletesController do
  describe "GET show", as: :visitor do
    let(:term) { "bolton" }

    it "calls `Autocomplete::AuthorNamesQuery`" do
      expect(Autocomplete::AuthorNamesQuery).to receive(:new).with(term).and_call_original
      get :show, params: { term: term, format: :json }
    end

    context 'with results' do
      let!(:author_name) { create :author_name, name: 'Bolton' }

      specify do
        get :show, params: { term: 'bol', format: :json }
        expect(json_response).to eq(
          [
            {
              'label' => author_name.name,
              'author_id' => author_name.author_id,
              'url' => "/authors/#{author_name.author_id}"
            }
          ]
        )
      end
    end
  end
end
