require 'rails_helper'

describe Taxa::ForceParentChangesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show" do
    let(:taxon) { create :tribe }

    before { sign_in create(:user, :editor) }

    specify { expect(get(:show, params: { taxa_id: taxon.id })).to render_template :show }
  end

  describe "POST create" do
    let(:taxon) { create :tribe }
    let(:new_parent) { create :family }
    let(:user) { create :user, :editor }

    before { sign_in user }

    it "calls `Taxa::Operations::ForceParentChange`" do
      expect(Taxa::Operations::ForceParentChange).
        to receive(:new).with(taxon, new_parent, user: user).and_call_original
      post :create, params: { taxa_id: taxon.id, new_parent_id: new_parent.id }
    end

    context 'when `new_parent_id` is missing' do
      context "when taxon isn't a genus" do
        let(:taxon) { create :tribe }

        specify do
          post :create, params: { taxa_id: taxon.id }

          expect(response).to render_template :show
          expect(response.request.flash[:alert]).to eq "A parent must be set."
        end
      end

      context 'when taxon is a genus' do
        let(:taxon) { create :genus }

        specify do
          post :create, params: { taxa_id: taxon.id }

          expect(response).to redirect_to catalog_path(taxon)
          expect(response.request.flash[:notice]).to eq "Successfully changed the parent."
        end
      end
    end
  end
end