require 'spec_helper'

describe Reference do
  let(:ward_ps) { create :author_name, name: 'Ward, P.S.' }
  let(:fisher_bl) { create :author_name, name: 'Fisher, B.L.' }

  describe 'relations' do
    it { is_expected.to have_many(:reference_author_names).dependent(:destroy) }
    it { is_expected.to have_many(:citations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:nestees).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:document).dependent(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to_not allow_values('<', '>').for(:doi) }

    describe '`bolton_key` uniqueness' do
      let!(:conflict) { create :article_reference, bolton_key: 'Batiatus 2000' }
      let!(:duplicate) { build_stubbed :article_reference }

      specify do
        expect { duplicate.bolton_key = conflict.bolton_key }.
          to change { duplicate.valid? }.from(true).to(false)
        expect(duplicate.errors[:bolton_key].first).to include "Bolton key has already been taken by"
        expect(duplicate.errors[:bolton_key].first).to include conflict.keey
      end
    end
  end

  it { is_expected.to be_versioned }
  it { is_expected.to delegate_method(:url).to(:document).allow_nil }
  it { is_expected.to delegate_method(:downloadable?).to(:document).allow_nil }

  describe 'callbacks' do
    describe '#after_save' do
      let!(:reference) { create :article_reference }

      it "invalidates caches" do
        References::Cache::Regenerate[reference]

        expect { reference.save! }.to change { reference.reload.plain_text_cache }.to(nil)
      end
    end
  end

  describe "scopes" do
    describe ".unreviewed_references" do
      let!(:unreviewed) { create :article_reference, review_state: "reviewing" }

      before { create :article_reference, review_state: "reviewed" }

      it "returns unreviewed references" do
        expect(described_class.unreviewed).to eq [unreviewed]
      end
    end

    describe ".order_by_author_names_and_year" do
      it "sorts by author_name plus year plus letter" do
        one = create :reference, author_name: 'Fisher', citation_year: '1910b'
        two = create :reference, author_name: 'Wheeler', citation_year: '1874'
        three = create :reference, author_name: 'Fisher', citation_year: '1910a'

        expect(described_class.order_by_author_names_and_year).to eq [three, one, two]
      end
    end
  end

  describe 'workflow' do
    let(:reference) { create :article_reference }

    it "starts as 'none'" do
      expect(reference).to be_none
      expect(reference.can_start_reviewing?).to be true
      expect(reference.can_finish_reviewing?).to be false
      expect(reference.can_restart_reviewing?).to be false
    end

    it "none transitions to start" do
      reference.start_reviewing!
      expect(reference).to be_reviewing
      expect(reference.can_start_reviewing?).to be false
      expect(reference.can_finish_reviewing?).to be true
      expect(reference.can_restart_reviewing?).to be false
    end

    it "start transitions to finish" do
      reference.start_reviewing!
      reference.finish_reviewing!
      expect(reference).not_to be_reviewing
      expect(reference).to be_reviewed
      expect(reference.can_start_reviewing?).to be false
      expect(reference.can_finish_reviewing?).to be false
      expect(reference.can_restart_reviewing?).to be true
    end

    it "reviewed can transition back to reviewing" do
      reference.start_reviewing!
      reference.finish_reviewing!
      reference.restart_reviewing!
      expect(reference).to be_reviewing
      expect(reference.can_start_reviewing?).to be false
      expect(reference.can_finish_reviewing?).to be true
      expect(reference.can_restart_reviewing?).to be false
    end
  end

  describe "#author_names_string_with_suffix" do
    describe "formatting" do
      it "consists of one author_name if that's all there is" do
        reference = build_stubbed :reference, author_names: [fisher_bl]
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L.'
      end

      it "separates multiple author_names with semicolons" do
        reference = build_stubbed :reference, author_names: [fisher_bl, ward_ps]
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L.; Ward, P.S.'
      end

      it "includes the author_names' suffix" do
        reference = build_stubbed :reference, author_names: [fisher_bl], author_names_suffix: '(ed.)'
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L. (ed.)'
      end
    end
  end

  describe "#author_names_string" do
    describe "formatting" do
      it "consists of one author_name if that's all there is" do
        reference = build_stubbed :reference, author_names: [fisher_bl]
        expect(reference.author_names_string).to eq 'Fisher, B.L.'
      end

      it "separates multiple author_names with semicolons" do
        reference = build_stubbed :reference, author_names: [fisher_bl, ward_ps]
        expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
      end
    end

    describe "updating, when things change" do
      let(:reference) { create :reference, author_names: [fisher_bl] }

      context "when an author_name is added" do
        before { reference.author_names << ward_ps }

        it "updates its `author_names_string`" do
          expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
        end
      end

      context "when an author_name is removed" do
        before { reference.author_names << ward_ps }

        it "updates its `author_names_string`" do
          expect { reference.author_names.delete ward_ps }.
            to change { reference.reload.author_names_string }.
            from('Fisher, B.L.; Ward, P.S.').to('Fisher, B.L.')
        end
      end

      context "when an author_name's name is changed" do
        before { reference.author_names = [ward_ps] }

        it "updates its `author_names_string`" do
          expect { ward_ps.update!(name: 'Fisher') }.
            to change { reference.reload.author_names_string }.
            from('Ward, P.S.').to('Fisher')
        end
      end
    end

    it "maintains the order in which they were added to the reference" do
      reference = create :reference, author_names: [ward_ps]
      fisher = create :author_name, name: 'Fisher'
      wilden = create :author_name, name: 'Wilden'
      reference.author_names << wilden
      reference.author_names << fisher

      expect(reference.author_names_string).to eq 'Ward, P.S.; Wilden; Fisher'
    end
  end

  describe "#principal_author_last_name" do
    context "when there are no authors" do
      let!(:reference) { build_stubbed :reference, author_names: [] }

      specify { expect(reference.principal_author_last_name).to eq nil }
    end

    context 'when there are authors' do
      let!(:reference) { build_stubbed :reference, author_names: [ward_ps, fisher_bl] }

      it "is the last name of the principal author" do
        expect(reference.principal_author_last_name).to eq 'Ward'
      end
    end
  end

  describe "changing `citation_year`" do
    context 'when `citation_year` contains a letter' do
      let(:reference) { create :reference, citation_year: '1910a' }

      it "sets `year` to the stated year, if present" do
        expect { reference.update!(citation_year: '2010b') }.
          to change { reference.reload.year }.from(1910).to(2010)
      end
    end

    context 'when `citation_year` contains a bracketed year' do
      let(:reference) { create :reference, citation_year: '1910a ["1958"]' }

      it "sets `year` to the stated year, if present" do
        expect { reference.update!(citation_year: '2010b ["2009"]') }.
          to change { reference.reload.year }.from(1958).to(2009)
      end
    end
  end

  describe "#what_links_here" do
    let(:reference) { build_stubbed :article_reference }

    it "calls `References::WhatLinksHere`" do
      expect(References::WhatLinksHere).to receive(:new).
        with(reference, predicate: false).and_call_original
      reference.what_links_here
    end
  end

  describe "#keey" do
    let(:bolton) { create :author_name, name: 'Bolton, B.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.' }

    context "when citation years with extra" do
      let(:reference) do
        create :article_reference, author_names: [bolton], citation_year: '1970a ("1971")'
      end

      specify { expect(reference.keey).to eq 'Bolton, 1970a' }
    end

    context 'when no authors' do
      let(:reference) do
        create :article_reference, author_names: [], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq '[no authors], 1970a' }
    end

    context 'when one author' do
      let(:reference) do
        create :article_reference, author_names: [bolton], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton, 1970a' }
    end

    context 'when two authors' do
      let(:reference) do
        create :article_reference, author_names: [bolton, fisher], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton & Fisher, 1970a' }
    end

    context 'when three authors' do
      let(:ward) { create :author_name, name: 'Ward, P.S.' }
      let(:reference) do
        create :article_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton <i>et al.</i>, 1970a' }
      specify { expect(reference.keey).to be_html_safe }
    end
  end

  describe "#keey_without_letters_in_year" do
    let(:reference) { create :reference, author_name: 'Bolton', citation_year: '1885g' }

    it "doesn't include the year ordinal" do
      expect(reference.keey_without_letters_in_year).to eq 'Bolton, 1885'
    end
  end
end
