# frozen_string_literal: true

module Protonyms
  class AutocompletesController < ApplicationController
    NUM_RESULTS = 10

    def show
      render json: serialized_protonyms
    end

    private

      def serialized_protonyms
        Autocomplete::ProtonymsSerializer[protonyms]
      end

      def protonyms
        Autocomplete::ProtonymsQuery[search_query, per_page: NUM_RESULTS]
      end

      def search_query
        (params[:q] || params[:qq]).lstrip
      end
  end
end
