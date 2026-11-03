# frozen_string_literal: true

module Astroturf
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class InvalidMatrixError < Error; end
  class UnknownPrimaryKeyStrategyError < Error; end
end
