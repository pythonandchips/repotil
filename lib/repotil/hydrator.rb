class Repotil
  class Repotil::Hydrator
    def hydrate_instance(klass, record)
      instance = klass.new
      record.attributes.reject{|key, value| key =~ /_id$/}.each do |key, value|
        if instance.respond_to?("#{key}=") && instance.respond_to?(key)
          instance.send("#{key}=", value)
        end
      end
      record.class.reflect_on_all_associations.each do |association|
        if instance.respond_to?("#{association.name}=") && instance.respond_to?(association.name)
          if record.association(association.name).loaded?
            value = hydrate_loaded_association(association, record)
          else
            klass = association_class(association.name.to_s)
            association_type = record.association(association.name).reflection.macro
            if association_type == :has_many
              value = Repotil::HasManyAssociationProxy.new(record.send("id"), association, klass)
            else
              foreign_key = record.send(association.foreign_key)
              value = Repotil::BelongsToAssociationProxy.new(foreign_key, association, klass)
            end
          end
          instance.send("#{association.name}=", value)
        end
      end
      instance
    end

    def hydrate_loaded_association(association, record)
      entity_name = association.name.to_s
      association_type = record.association(association.name).reflection.macro
      if association_type == :has_many
        records = record.send(association.name).to_a
        records.map do |associated_record|
          hydrate_instance(association_class(entity_name), associated_record)
        end
      else
        hydrate_instance(association_class(entity_name), record.send(association.name))
      end
    end

    def belongs_to_association?(key, value)
      key =~ /_id$/ && value
    end

    def association_name(key)
      key.gsub(/_id$/, '')
    end

    def association_class(class_name)
      Object.const_get(class_name.classify)
    end

  end
end
