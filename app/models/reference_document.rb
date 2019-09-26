class ReferenceDocument < ApplicationRecord
  belongs_to :reference

  validate :check_url

  before_validation :add_protocol_to_url
  after_save :invalidate_reference_caches!

  has_attached_file :file,
    url: ':s3_domain_url',
    path: ':id/:filename',
    bucket: 'antcat',
    storage: :s3,
    s3_credentials: (Rails.env.production? ? '/data/antcat/shared/config/' : Rails.root + 'config/') + 's3.yml',
    s3_permissions: 'authenticated-read',
    s3_region: 'us-east-1',
    s3_protocol: 'http'
  before_post_process :transliterate_file_name
  do_not_validate_attachment_file_type :pdf
  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }

  def pdf
    true
  end

  def host= host
    return unless hosted_by_us?
    # TODO: Investigate `Rails/SkipsModelValidations`.
    update_attribute :url, "http://#{host}/documents/#{id}/#{file_file_name}" # rubocop:disable Rails/SkipsModelValidations
  end

  def downloadable?
    url.present? && !hosted_by_antbase? && !hosted_by_hol?
  end

  def actual_url
    hosted_by_us? ? s3_url : url
  end

  private

    def transliterate_file_name
      extension = File.extname(file_file_name).gsub(/^\.+/, '')
      filename = file_file_name.gsub(/\.#{extension}$/, '')
      file.instance_write(:file_name, "#{ActiveSupport::Inflector.parameterize(filename)}.#{ActiveSupport::Inflector.parameterize(extension)}")
    end

    def hosted_by_hol?
      url.present? && url =~ %r{^https?://128.146.250.117}
    end

    def hosted_by_antbase?
      url.present? && url =~ %r{^https?://antbase\.org}
    end

    def check_url
      return if Rails.env.development? # HACK
      return if file_file_name.present? || url.blank?
      # This is to avoid authentication problems when a URL to one of "our" files is copied
      # to another reference (e.g., nested).
      return if url =~ /antcat/
      return if hosted_by_hol? || hosted_by_antbase?

      URI.parse(url.gsub(' ', '%20'))
    rescue URI::InvalidURIError
      errors.add :url, 'is not in a valid format'
    end

    def hosted_by_us?
      file_file_name.present?
    end

    def add_protocol_to_url
      self.url = "http://" + url if url.present? && url !~ %r{^http://}
    end

    def s3_url
      file.expiring_url 1.day.to_i # Seconds.
    end

    def invalidate_reference_caches!
      reference&.invalidate_caches
    end
end
