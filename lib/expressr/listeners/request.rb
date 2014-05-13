module Expressr
  module Listeners
    class Request < Noder::Events::Listeners::Base
      def call(env)
        env[:request] = Expressr::Request.new(env[:request_env])
        callback.call(env) if callback
        env
      end
    end
  end
end
