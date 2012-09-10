conn = { :adapter => 'sqlite3', :database => ':memory:' }

ActiveRecord::Base.establish_connection(conn)

class TestEntity
  attr_accessor :id, :name, :email, :has_one_association_entity,
                :has_many_association_entities
end

class HasOneAssociationEntity
  attr_accessor :id, :name, :email, :secret_value

  def add_numbers(n1, n2, n3)
    n1 + n2 + n3
  end

  def run_block(&block)
    block.call
  end
end
class HasOneAssociationEntity
  attr_accessor :id, :name, :email, :secret_value
end

class HasManyAssociationEntity
  attr_accessor :id, :name, :email, :secret_value, :test_entity
end

class AnotherTestEntity
  attr_accessor :id, :name, :email, :secret_value
end

module DataEntities
  class TestEntity < ActiveRecord::Base
    belongs_to :has_one_association_entity
    has_many   :has_many_association_entities
    connection.create_table :test_entities, :force => true do |t|
      t.string :name, :email, :secret_value
      t.integer :has_one_association_entity_id
      t.timestamps
    end

    def self.eager_load_association(id)
      self.joins(:has_one_association_entity, :has_many_association_entities).
        includes(:has_one_association_entity, :has_many_association_entities).
        where("test_entities.id = ?", id).first
    end
  end

  class AnotherTestEntity < ActiveRecord::Base
    connection.create_table :another_test_entities, :force => true do |t|
      t.string :name, :email, :secret_value
      t.timestamps
    end
  end

  class HasOneAssociationEntity < ActiveRecord::Base
    connection.create_table :has_one_association_entities, :force => true do |t|
      t.string :name, :email, :secret_value
      t.timestamps
    end
  end

  class HasManyAssociationEntity < ActiveRecord::Base
    belongs_to :test_entity
    connection.create_table :has_many_association_entities, :force => true do |t|
      t.string :name, :email, :secret_value
      t.integer :test_entity_id
      t.timestamps
    end
  end
end
