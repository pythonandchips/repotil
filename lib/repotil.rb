class Repotil
  def find(klass, id)
    record = DataEntities::TestEntity.find(id)
    instance = klass.new
    record.attributes.each do |key, value|
      instance.instance_variable_set("@#{key}", value)
    end
    instance
  end

  def save(instance)
    attributes = extract_attributes(instance)
    if instance.instance_variable_get("@id")
      update(instance, attributes)
    else
      create(instance, attributes)
    end
    instance
  end

  def delete(instance)
    DataEntities::TestEntity.destroy(instance.instance_variable_get("@id"))
  end

  private

  def extract_attributes(instance)
    DataEntities::TestEntity.column_names.inject({}) do |attributes, column_name|
      attributes[column_name] = instance.instance_variable_get("@#{column_name}")
      attributes
    end
  end

  def create(instance, attributes)
    saved_instance = DataEntities::TestEntity.create(attributes)
    instance.instance_variable_set("@id", saved_instance.id)
  end

  def update(instance, attributes)
    entity = DataEntities::TestEntity.new(attributes)
    entity.id = instance.instance_variable_get("@id")
    entity.instance_variable_set("@new_record", false)
    entity.save!
  end
end
