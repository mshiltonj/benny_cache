class ARFaker

  def save
    self.class.class_variable_get(:@@after_save_callbacks).each do |cb|
      self.send(cb)
    end
  end

  def destroy
    self.class.class_variable_get(:@@after_destroy_callbacks).each do |cb|
      self.send(cb)
    end
  end

  def self.after_save(*methods)
    unless self.class_variable_defined?(:@@after_save_callbacks)
      self.class_variable_set(:@@after_save_callbacks, [])
    end
    self.class_variable_get(:@@after_save_callbacks).push(*methods)
  end

  def self.after_destroy(*methods)
    unless self.class_variable_defined?(:@@after_destroy_callbacks)
      self.class_variable_set(:@@after_destroy_callbacks, [])
    end

    self.class_variable_get(:@@after_destroy_callbacks).push(*methods)
  end

end


class ModelCacheFake < ARFaker
  include BennyCache::Model

  attr_accessor :id, :other_id, :x, :y

  benny_model_index :other_id, [:x, :y]
  benny_data_index :stuff

  def stuff
    [:stuff1, :stuff2]
  end

  def method_to_cache(*options)
    return options
  end
  benny_method_index :method_to_cache
end

class ModelCacheFakeWithNs < ARFaker
  include BennyCache::Model
  benny_model_ns :custom_ns

  attr_accessor :id, :other_id
end

class RelatedCacheFake < ARFaker
  include BennyCache::Related
  benny_related_index ":model_id/ModelCacheFake/stuff"

  benny_related_method ":model_id/ModelCacheFake/method_to_cache"

  attr_accessor :model_id

end


