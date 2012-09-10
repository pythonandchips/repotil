class Repotil
  class Repotil::BelongsToAssociationProxy
    self.instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }
    def initialize(foreign_key, association, klass)
      @foreign_key = foreign_key
      @association = association
      @klass = klass
    end

    protected

    def respond_to_missing?(method_name, include_private)
      @klass.instance_methods.include?(method_name)
    end

    def method_missing(method_name, *args, &block)
      if @klass.instance_methods.include?(method_name)
        @instance ||= hydrated_association
        @instance.send(method_name, *args, &block)
      else
        super(method_name, *args, &block)
      end
    end

    def hydrated_association
      data_model = @association.klass.find_by_id(@foreign_key)
      hydrator = Hydrator.new
      hydrator.hydrate_instance(@klass, data_model)
    end
  end
end
