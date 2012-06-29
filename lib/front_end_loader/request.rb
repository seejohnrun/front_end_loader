module FrontEndLoader
  class Request
    def initialize(experiment, session, method, name, path, params, data, response_block)
      @experiment = experiment
      @session = session
      @method = method
      @name = name
      @path = path
      @params = URI.encode(@experiment.default_parameters.merge(params).map { |k,v| "#{k}=#{v}" }.join('&'))
      @data = data
      @response_block = response_block
    end

    def run
      response = nil
      if [:get, :delete].include?(@method)
        response = @experiment.time_call(@name) do
          @session.__send__(@method, "#{@path}?#{@params}")
        end
      else
        response = @experiment.time_call(@name) do
          @session.__send__(@method, "#{@path}?#{@params}", @data, {'Content-Type' => 'application/json'})
        end
      end
      if @response_block && response.is_a?(Patron::Response)
        @response_block.call(response)
      end
    end
  end
end