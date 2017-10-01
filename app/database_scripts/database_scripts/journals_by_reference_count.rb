module DatabaseScripts
  class JournalsByReferenceCount < DatabaseScript
    def results
      Journal.joins("LEFT JOIN `references` ON `references`.journal_id = journals.id")
        .select("journals.*, COUNT(references.id) AS reference_count")
        .group("journals.id")
        .order("reference_count DESC")
        .map { |journal| [journal.id, journal.reference_count] }
    end

    def render
      as_table do |t|
        t.header :journal, :reference_count

        t.rows do |journal_id, reference_count|
          [ "%journal#{journal_id}", reference_count ]
        end
      end
    end
  end
end

__END__
topic_areas: [references]