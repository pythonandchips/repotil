class Repotil
  class Repotil::HasManyAssociationProxy
    def initialize(foreign_key, association, klass)
      @foreign_key = foreign_key
      @association = association
      @klass = klass
    end

    def each(&block)
      hydrator = Repotil::Hydrator.new
      records.each do |record|
        instance = hydrator.hydrate_instance(@klass, record)
        yield(instance)
      end
    end


    def length
      records.length
    end

    private

    def records
      @records ||= @association.klass.where("#{@association.foreign_key} = #{@foreign_key}")
    end
  end
end
