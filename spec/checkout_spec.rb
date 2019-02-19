require 'spec_helper'
require 'yaml'
require 'checkout'

RSpec.describe Checkout do
  let(:pricing_rules) { YAML.load_file('pricing_rules.yml') }
  let(:checkout) { Checkout.new(pricing_rules) }
  let(:item1) { 'ipd' }
  let(:ipad) { { 'name' => 'Super iPad', 'price' => 549.99, 'bulk_discount' => -50.0 } }

  describe '#scan' do
    it 'adds item to items list' do
      expect { checkout.scan!(item1) }.to change { checkout.items.count }.from(0).to(1)
      expect(checkout.items.first).to eq(ipad)
    end

    context 'multiple items to scan' do
      let(:item2) { 'mbp' }
      let(:item3) { 'atv' }

      it 'adds 3 items to items list' do
        expect { checkout.scan!(item1) }.to change { checkout.items.count }.from(0).to(1)
        expect { checkout.scan!(item2) }.to change { checkout.items.count }.from(1).to(2)
        expect { checkout.scan!(item3) }.to change { checkout.items.count }.from(2).to(3)
      end
    end

    context 'item does not exist' do
      it 'does not add any items' do
        expect { checkout.scan!('srs') }.to_not change { checkout.items.count }
      end
    end
  end

  describe '#total' do
    context 'no items scanned' do
      it 'show the total cost of all items' do
        expect(checkout.total).to equal(0)
      end
    end

    context 'more than 3 of one item' do
      let(:items_list) { %w[atv atv atv vga] }
      before do
        items_list.each { |item| checkout.scan!(item) }
      end

      it 'returns total cost of all items' do
        expect(checkout.total).to eq(249.00)
      end
    end

    context 'more than 4 ipads' do
      let(:items_list) { %w[atv ipd ipd atv ipd ipd ipd] }
      before do
        items_list.each { |item| checkout.scan!(item) }
      end

      it 'returns total cost of all items' do
        expect(checkout.total).to eq(2718.95)
      end
    end

    context 'one of each item' do
      let(:items_list) { %w[mbp vga ipd] }
      before do
        items_list.each { |item| checkout.scan!(item) }
      end

      it 'returns total cost of all items' do
        expect(checkout.total).to eq(1979.98)
      end
    end
  end
end
