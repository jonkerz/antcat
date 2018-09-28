require 'spec_helper'

describe ReferenceDecorator do
  let(:nil_decorator) { described_class.new nil }

  describe "#format_reference_document_link" do
    let!(:reference) { build_stubbed :reference }

    before do
      allow(reference).to receive(:downloadable?).and_return true
      allow(reference).to receive(:url).and_return 'example.com'
    end

    it "creates a link" do
      expect(reference.decorate.format_reference_document_link).
        to eq '<a href="example.com">PDF</a>'
    end
  end

  describe "#plain_text" do
    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }
      let(:reference) do
        create :unknown_reference, author_names: author_names,
          citation_year: "1874", title: "Les fourmis de la Suisse.", citation: '32 pp.'
      end

      it "escapes everything, buts let italics through" do
        reference.author_names = [create(:author_name, name: '<script>')]
        expect(reference.decorate.plain_text).
          to eq '&lt;script&gt; 1874. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the citation year" do
        reference.update citation_year: '<script>'
        expect(reference.decorate.plain_text).
          to eq 'Ward, P. S. &lt;script&gt;. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the title" do
        reference.update title: '<script>'
        expect(reference.decorate.plain_text).to eq 'Ward, P. S. 1874. &lt;script&gt;. 32 pp.'
      end

      it "escapes the title but leave the italics alone" do
        reference.update title: '*foo*<script>'
        expect(reference.decorate.plain_text).to eq 'Ward, P. S. 1874. <i>foo</i>&lt;script&gt;. 32 pp.'
      end

      it "escapes the date" do
        reference.update date: '1933>'
        expect(reference.decorate.plain_text).
          to eq 'Ward, P. S. 1874. Les fourmis de la Suisse. 32 pp. [1933&gt;]'
      end
    end
  end

  describe "#format_date" do
    def check_format_date date, expected
      expect(nil_decorator.send(:format_date, date)).to eq expected
    end

    it "uses ISO 8601 format for calendar dates" do
      check_format_date '20101213', '2010-12-13'
    end

    it "handles years without months and days" do
      check_format_date '201012', '2010-12'
    end

    it "handles years with months but without days" do
      check_format_date '2010', '2010'
    end

    it "handles missing dates" do
      check_format_date '', ''
    end
  end

  describe "#format_review_state" do
    let(:reference) { build_stubbed :article_reference }

    context "when review_state is 'reviewed'" do
      before { reference.review_state = 'reviewed' }

      specify { expect(reference.decorate.format_review_state).to eq 'Reviewed' }
    end

    context "when review_state is 'reviewing'" do
      before { reference.review_state = 'reviewing' }

      specify { expect(reference.decorate.format_review_state).to eq 'Being reviewed' }
    end

    context "when review_state is 'none'" do
      before { reference.review_state = 'none' }

      specify { expect(reference.decorate.format_review_state).to eq '' }
    end

    context "when review_state is empty string" do
      before { reference.review_state = '' }

      specify { expect(reference.decorate.format_review_state).to eq '' }
    end

    context "when review_state is nil" do
      before { reference.review_state = nil }

      specify { expect(reference.decorate.format_review_state).to eq '' }
    end
  end
end
