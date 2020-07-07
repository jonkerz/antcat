# frozen_string_literal: true

# TODO: Names are randomly generated for each associated rank (for example the genus epithet of a species is not it's genus epithet).
# TODO: Assign fossil status of `Taxon` associations per the initial factory.

FactoryBot.define do
  factory :base_taxon, class: 'Taxon' do
    transient do
      name_string {}
    end

    after(:create) do |taxon, evaluator|
      if evaluator.name_string
        # HACK: Because just assigning before did not work without `accepts_nested_attributes_for`.
        taxon.name.update!(name: evaluator.name_string)
        taxon.reload # For `taxa.name_cache`.
      end
    end

    valid

    factory :family, class: Rank::FAMILY.to_s, aliases: [:any_taxon] do
      association :name, factory: :family_name
      genus_group_name_protonym
    end

    factory :subfamily, class: Rank::SUBFAMILY.to_s do
      association :name, factory: :subfamily_name
      genus_group_name_protonym
    end

    factory :tribe, class: Rank::TRIBE.to_s do
      association :name, factory: :tribe_name
      genus_group_name_protonym
      subfamily
    end

    factory :subtribe, class: Rank::SUBTRIBE.to_s do
      association :name, factory: :subtribe_name
      genus_group_name_protonym
      tribe
      subfamily { |taxon| taxon.tribe.subfamily }
    end

    factory :genus, class: Rank::GENUS.to_s do
      association :name, factory: :genus_name
      genus_group_name_protonym
      tribe
      subfamily { |taxon| taxon.tribe&.subfamily }
    end

    factory :subgenus, class: Rank::SUBGENUS.to_s do
      association :name, factory: :subgenus_name
      genus_group_name_protonym
      genus
    end

    factory :species, class: Rank::SPECIES.to_s do
      association :name, factory: :species_name
      species_group_name_protonym
      genus
    end

    factory :subspecies, class: Rank::SUBSPECIES.to_s do
      association :name, factory: :subspecies_name
      species_group_name_protonym
      species
      genus
    end

    factory :infrasubspecies, class: Rank::INFRASUBSPECIES.to_s do
      association :name, factory: :infrasubspecies_name
      species_group_name_protonym
      subspecies
      species
      genus
    end

    # Statuses.
    trait :valid do
      status { Status::VALID }
    end

    trait :synonym do
      status { Status::SYNONYM }
      with_current_taxon
    end

    trait :homonym do
      status { Status::HOMONYM }
      homonym_replaced_by { Family.first || FactoryBot.create(:family) }
    end

    trait :obsolete_combination do
      status { Status::OBSOLETE_COMBINATION }
      with_current_taxon
    end

    trait :obsolete_classification do
      status { Status::OBSOLETE_CLASSIFICATION }
      with_current_valid_taxon
    end

    trait :unidentifiable do
      status { Status::UNIDENTIFIABLE }
    end

    trait :unavailable do
      status { Status::UNAVAILABLE }
    end

    trait :excluded_from_formicidae do
      status { Status::EXCLUDED_FROM_FORMICIDAE }
    end

    trait :unavailable_misspelling do
      status { Status::UNAVAILABLE_MISSPELLING }
    end

    # Parallel statuses.
    trait :fossil do
      fossil { true }
    end

    trait :unresolved_homonym do
      unresolved_homonym { true }
    end

    trait :original_combination do
      original_combination { true }
    end

    trait :incertae_sedis_in_family do
      incertae_sedis_in { Rank::INCERTAE_SEDIS_IN_FAMILY }
    end

    trait :incertae_sedis_in_subfamily do
      incertae_sedis_in { Rank::INCERTAE_SEDIS_IN_SUBFAMILY }
    end

    # Misc.
    trait :with_current_taxon do
      current_taxon { Family.first || FactoryBot.create(:family) }
    end

    trait :with_history_item do
      after :create do |taxon|
        create :taxon_history_item, taxon: taxon
      end
    end

    trait :genus_group_name_protonym do
      association :protonym, :genus_group_name
    end

    trait :species_group_name_protonym do
      association :protonym, :species_group_name
    end
  end
end
