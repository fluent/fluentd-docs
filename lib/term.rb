require "rubygems"
require "coderay"

module CodeRay
  module Scanners
    class Term < Scanner
      # include CodeRay::Streamable
      register_for :term

      def scan_tokens (tokens, options)
        prev = nil

        until eos?
          line = scan(/.*?\n/)
          if line =~ /^(\$)(.*)/
            tokens << [$1, [:comment]]
            tokens << [$2 + "\n", [:function]]
          elsif prev =~ /\\$/
            tokens << [line, [:function]]
          else
            tokens << [line, [:string]]
          end
          prev = line
        end

        return tokens
      end
    end
  end
end
