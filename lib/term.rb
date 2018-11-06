require "rubygems"
require "coderay"

module CodeRay
  module Scanners
    class Term < Scanner
      # include CodeRay::Streamable
      register_for :term

      def scan_tokens(encoder, options)
        prev = nil

        until eos?
          line = scan(/.*?\n/)
          if line =~ /^(\$)(.*)/
            encoder.token($1, [:comment])
            encoder.token($2 + "\n", [:function])
          elsif prev =~ /\\$/
            encoder.token(line, [:function])
          else
            encoder.token(line, [:string])
          end
          prev = line
        end

        return encoder
      end
    end
  end
end
