module Expressr
  class RouteNode
    def initialize(proc, next_node, options={})
      @proc = proc
      @next_node = next_node
      @additional_arguments = options[:additional_arguments] || []
      @has_continued = false
    end

    def call(request, response)
      @request = request
      @response = response
      instance_exec(request, response, &@proc)
      continue unless @has_continued
    end

    def continue
      @has_continued = true
      @next_node.call(@request, @response, *@additional_arguments)
    end
  end
end
