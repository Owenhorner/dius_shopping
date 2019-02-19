class Checkout
  attr_reader :items

  def initialize(pricing_rules)
    @pricing_rules = pricing_rules
    @items = []
  end

  def scan!(item_sku)
    item = @pricing_rules[item_sku]
    return self unless item
    @items << item
    self
  end

  def total
    items_total = @items
    items_total.concat(add_bulk_pricing)
    items_total.concat(add_specials)
    items_total.concat(add_additional_items)
    items_total.reduce(0) { |total, item| total += item['price'].to_f }
  end

  private

  def add_additional_items
    @items.map do |item|
      if item['additional']
        item['additional'].map do |additional_item|
          @pricing_rules[additional_item].merge('price' => 0)
        end
      end
    end.flatten.compact
  end

  def add_bulk_pricing
    select_and_group_items('bulk_discount').map do |name, bulk_items|
      if bulk_items.count > 4
        bulk_items.map { |bulk_item| bulk_item.merge('price' => bulk_item['bulk_discount']) }
      end
    end.flatten.compact
  end

  def add_specials
    select_and_group_items('special').map do |name, bulk_items|
      item = bulk_items.first
      (1..(bulk_items.count / 3)).map do
        item.merge('price' => -item['price'])
      end
    end.flatten
  end

  def select_and_group_items(field)
    @items.select { |item| item[field] }
      .group_by { |item| item['name'] }
  end
end
