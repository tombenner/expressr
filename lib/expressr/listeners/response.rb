module Expressr
  module Listeners
    class Response < Noder::Events::Listeners::Base
      def call(env)
        env[:response] = Expressr::Response.new(env)
        callback.call(env) if callback
        env
      end
    end
  end
end
