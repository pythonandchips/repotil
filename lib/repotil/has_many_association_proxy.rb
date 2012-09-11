class Repotil
  class Repotil::HasManyAssociationProxy
    include Enumerable
    def initialize(foreign_key, association, klass)
      @foreign_key = foreign_key
      @association = association
      @klass = klass
      @hydrator = Repotil::Hydrator.new
    end

    def [](index)
      records[index]
    end

    def <<(item)
      records << item
    end

    def each(&block)
      records.each do |record|
        yield(record)
      end
    end

    def length
      records.length
    end

    private

    def records
      @records ||= hydrate_records
    end

    def hydrate_records
      results = @association.klass.where("#{@association.foreign_key} = #{@foreign_key}")
      results.map{|record| @hydrator.hydrate_instance(@klass, record) }
    end
  end
end
