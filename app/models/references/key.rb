# frozen_string_literal: true

module References
  class Key
    attr_private_initialize :reference

    # Looks like: "Abdul-Rassoul, Dawah & Othman, 1978b".
    def key_with_citation_year
      authors_for_key << ', ' << citation_year
    end

    # Normal key: "Bolton, 1885g".
    # This:       "Bolton, 1885".
    def key_with_year
      authors_for_key << ', ' << year.to_s
    end

    def authors_for_key
      names = author_names.map(&:last_name)

      case names.size
      when 0 then '[no authors]' # TODO: This can still happen in the reference form.
      when 1 then names.first.to_s
      when 2 then "#{names.first} & #{names.second}"
      else        "#{names.first} <i>et al.</i>"
      end.html_safe
    end

    private

      delegate :citation_year, :year, :author_names, to: :reference, private: true
  end
end