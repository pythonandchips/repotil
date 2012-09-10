require 'active_support/inflector'
require 'repotil/belongs_to_association_proxy'
require 'repotil/has_many_association_proxy'
require 'repotil/hydrator'

class Repotil
  def find(klass, id_or_method, *args)
    hydrator = Hydrator.new
    data_class = discover_data_type(klass)
    records = find_records(data_class, id_or_method, *args)
    if records.kind_of?(Array)
      records.map do |record|
        hydrator.hydrate_instance(klass, record)
      end
    else
      hydrator.hydrate_instance(klass, records)
    end
  end

  def save(instance)
    data_class = discover_data_type(instance.class)
    attributes = extract_attributes(instance, data_class)
    if instance.instance_variable_get("@id")
      update(instance, data_class, attributes)
    else
      create(instance, data_class, attributes)
    end
    instance
  end

  def delete(instance)
    data_class = discover_data_type(instance.class)
    data_class.destroy(instance.instance_variable_get("@id"))
  end

  private

  def find_records(data_class, id_or_method, *args)
    if id_or_method.kind_of?(Fixnum)
      records = data_class.find(id_or_method)
    else
      records = data_class.send(id_or_method, *args)
    end
  end

  def discover_data_type(klass)
    DataEntities.const_get(klass.name)
  end

  def extract_attributes(instance, data_class)
    data_class.column_names.inject({}) do |attributes, column_name|
      attributes[column_name] = instance.instance_variable_get("@#{column_name}")
      attributes
    end
  end

  def create(instance, data_class, attributes)
    saved_instance = data_class.create(attributes)
    instance.instance_variable_set("@id", saved_instance.id)
  end

  def update(instance, data_class, attributes)
    entity = data_class.new(attributes)
    entity.id = instance.instance_variable_get("@id")
    entity.instance_variable_set("@new_record", false)
    entity.save!
  end
end
