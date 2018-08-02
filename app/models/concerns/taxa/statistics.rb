module Taxa::Statistics
  extend ActiveSupport::Concern

  module ClassMethods
    def massage_count count, rank, statistics
      count.keys.each do |fossil, status|
        value = count[[fossil, status]]
        extant_or_fossil = fossil ? :fossil : :extant
        statistics[extant_or_fossil] ||= {}
        statistics[extant_or_fossil][rank] ||= {}
        statistics[extant_or_fossil][rank][status] = value
      end
    end
  end

  protected

    # TODO this is really slow; figure out how to add database indexes for this.
    def get_statistics ranks, valid_only: false
      statistics = {}

      ranks_with_taxa = ranks.map do |rank|
        [rank, send(rank)]
      end

      ranks_with_taxa.each do |rank, taxa|
        taxa = taxa.valid if valid_only
        count = taxa.group(:fossil, :status).count
        delete_original_combinations count unless valid_only

        self.class.massage_count count, rank, statistics
      end
      statistics
    end

  private

    def delete_original_combinations count
      count.delete [true, Status::ORIGINAL_COMBINATION]
      count.delete [false, Status::ORIGINAL_COMBINATION]
    end
end
