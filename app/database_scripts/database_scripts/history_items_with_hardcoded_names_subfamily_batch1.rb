# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithHardcodedNamesSubfamilyBatch1 < DatabaseScript
    NAMES = Subfamily.order(:name_cache).pluck(:name_cache)
    NAMES_REGEX = "(#{NAMES.join('|')})"

    def statistics
      <<~STR.html_safe
        Checked (#{NAMES.size}): #{NAMES.join(', ')}
      STR
    end

    def results
      raise 'should not happen(tm)' if NAMES.join.match?(/[^A-Za-z]/)

      mega_like = NAMES.join("%' OR taxt LIKE '%")
      HistoryItem.taxts_only.where("taxt LIKE '%#{mega_like}%'")
    end

    def render
      as_table do |t|
        t.caption "Results: #{cached_results.size}"
        t.header 'History item', 'Protonym', 'taxt',
          'taxt without missing/unmissing/misspelling tags', 'Only OK tags?'

        t.rows do |history_item|
          taxt = history_item.taxt
          taxt_without_ok_tags = remove_ok_tags(taxt)

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxt,
            taxt_without_ok_tags,
            (bold_notice('Yes') unless taxt_without_ok_tags.match?(NAMES_REGEX))
          ]
        end
      end
    end

    private

      def remove_ok_tags taxt
        taxt.
          gsub(Taxt::MISSING_OR_UNMISSING_TAG_REGEX, '').
          gsub(Taxt::MISSPELLING_TAG_REGEX, '')
      end
  end
end

__END__

title: History items with hardcoded names (subfamily batch 1)

section: missing-tags
category: Taxt
tags: [very-slow]

description: >
  See [AntCat issue #63](/issues/63)

related_scripts:
  - HistoryItemsWithHardcodedNamesGenusBatch1
  - HistoryItemsWithHardcodedNamesGenusBatch2
  - HistoryItemsWithHardcodedNamesGenusBatch3
  - HistoryItemsWithHardcodedNamesSubfamilyBatch1
  - HistoryItemsWithHardcodedNamesTribeBatch1
