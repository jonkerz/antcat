# frozen_string_literal: true

class Issue < ApplicationRecord
  include Commentable
  include Trackable

  TITLE_MAX_LENGTH = 100

  belongs_to :user
  belongs_to :closer, class_name: "User", optional: true

  validates :description, presence: true
  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }

  scope :open, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }
  scope :open_help_wanted, -> { open.where(help_wanted: true) }

  has_paper_trail
  trackable parameters: proc { { title: title } }

  def self.any_help_wanted_open?
    open_help_wanted.any?
  end

  def closed?
    !open?
  end

  def close! user
    update!(open: false, closer: user)
  end

  def reopen!
    update!(open: true, closer: nil)
  end
end
