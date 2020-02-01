require 'rails_helper'

describe NotificationDecorator do
  describe "#link_attached" do
    let(:notification) { build_stubbed :notification, attached: attached }
    let(:decorated) { notification.decorate }

    context "when `attached` is an `Issue`" do
      let(:attached) { build_stubbed :issue }

      specify { expect(decorated.link_attached).to eq %(issue <a href="/issues/#{attached.id}">#{attached.title}</a>) }
    end

    context "when `attached` is a `SiteNotice`" do
      let(:attached) { build_stubbed :site_notice }

      specify { expect(decorated.link_attached).to eq %(site notice <a href="/site_notices/#{attached.id}">#{attached.title}</a>) }
    end

    context "when `attached` is a `Feedback`" do
      let(:attached) { build_stubbed :feedback }

      specify { expect(decorated.link_attached).to eq %(feedback <a href="/feedback/#{attached.id}">##{attached.id}</a>) }
    end
  end
end