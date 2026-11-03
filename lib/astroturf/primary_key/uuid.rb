# frozen_string_literal: true

require "digest"

module Astroturf
  module PrimaryKey
    class Uuid
      DEFAULT_NAMESPACE = "astroturf"

      attr_reader :namespace

      def initialize(namespace: DEFAULT_NAMESPACE)
        @namespace = namespace
        @counter = 0
      end

      def next_id(label = nil, _context = {})
        @counter += 1
        name = label ? "#{label}" : "record_#{@counter}"
        generate_uuid_v5(@namespace, name)
      end

      def reset!
        @counter = 0
      end

      private

      # Generates a standard RFC 4122 compliant UUIDv5 using SHA-1
      def generate_uuid_v5(ns, name)
        hash = Digest::SHA1.hexdigest("#{ns}:#{name}")
        time_low = hash[0...8]
        time_mid = hash[8...12]
        time_hi = ((hash[12...16].to_i(16) & 0x0fff) | 0x5000).to_s(16).rjust(4, "0")
        clock_seq = ((hash[16...20].to_i(16) & 0x3fff) | 0x8000).to_s(16).rjust(4, "0")
        node = hash[20...32]

        "#{time_low}-#{time_mid}-#{time_hi}-#{clock_seq}-#{node}"
      end
    end
  end
end
