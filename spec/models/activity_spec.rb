require "spec_helper"

describe Activity, :feed do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :action }
  it { is_expected.to validate_inclusion_of(:action).in_array Activity::ACTIONS }

  describe ".create_for_trackable" do
    context "when feed is enabled" do
      it "creates activities" do
        expect { described_class.create_for_trackable(nil, :custom) }.
          to change { described_class.count }.by 1
      end
    end

    context "when feed is disabled" do
      before { Feed.enabled = false }

      it "doesn't create activities" do
        expect { described_class.create_for_trackable(nil, :custom) }.
          not_to change { described_class.count }
      end
    end
  end

  describe '#pagination_page' do
    let!(:activity_1)  { create :activity, automated_edit: true }
    let!(:activity_2)  { create :activity }
    let!(:activity_3)  { create :activity }
    let!(:activity_4)  { create :activity, automated_edit: true }
    let!(:activity_5)  { create :activity }

    before do
      expect(described_class).to receive(:per_page).at_least(:once).and_return(2)
    end

    context 'when not using filters' do
      let(:activites) { described_class.all }

      specify do
        expect(activity_1.pagination_page(activites)).to eq 3
        expect(activity_2.pagination_page(activites)).to eq 2
        expect(activity_3.pagination_page(activites)).to eq 2
        expect(activity_4.pagination_page(activites)).to eq 1
        expect(activity_5.pagination_page(activites)).to eq 1
      end
    end

    context 'when using filters' do
      let(:activites) { described_class.non_automated_edits }

      specify do
        expect(activity_2.pagination_page(activites)).to eq 2
        expect(activity_3.pagination_page(activites)).to eq 1 # Different page when not using filters.
        expect(activity_5.pagination_page(activites)).to eq 1
      end
    end
  end
end
