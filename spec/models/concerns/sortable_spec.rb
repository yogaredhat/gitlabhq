require 'spec_helper'

describe Sortable do
  describe '.order_by' do
    let(:relation) { Group.all }

    describe 'ordering by id' do
      it 'ascending' do
        expect(relation).to receive(:reorder).with(id: :asc)

        relation.order_by('id_asc')
      end

      it 'descending' do
        expect(relation).to receive(:reorder).with(id: :desc)

        relation.order_by('id_desc')
      end
    end

    describe 'ordering by created day' do
      it 'ascending' do
        expect(relation).to receive(:reorder).with(created_at: :asc)

        relation.order_by('created_asc')
      end

      it 'descending' do
        expect(relation).to receive(:reorder).with(created_at: :desc)

        relation.order_by('created_desc')
      end

      it 'order by "date"' do
        expect(relation).to receive(:reorder).with(created_at: :desc)

        relation.order_by('created_date')
      end
    end

    describe 'ordering by name' do
      it 'ascending' do
        expect(relation).to receive(:reorder).with("lower(name) asc")

        relation.order_by('name_asc')
      end

      it 'descending' do
        expect(relation).to receive(:reorder).with("lower(name) desc")

        relation.order_by('name_desc')
      end
    end

    describe 'ordering by Updated Time' do
      it 'ascending' do
        expect(relation).to receive(:reorder).with(updated_at: :asc)

        relation.order_by('updated_asc')
      end

      it 'descending' do
        expect(relation).to receive(:reorder).with(updated_at: :desc)

        relation.order_by('updated_desc')
      end
    end

    it 'does not call reorder in case of unrecognized ordering' do
      expect(relation).not_to receive(:reorder)

      relation.order_by('random_ordering')
    end
  end

  describe 'sorting groups' do
    def ordered_group_names(order)
      Group.all.order_by(order).map(&:name)
    end

    let!(:ref_time) { Time.parse('2018-05-01 00:00:00') }
    let!(:group1) { create(:group, name: 'aa', id: 1, created_at: ref_time - 15.seconds, updated_at: ref_time) }
    let!(:group2) { create(:group, name: 'AAA', id: 2, created_at: ref_time - 10.seconds, updated_at: ref_time - 5.seconds) }
    let!(:group3) { create(:group, name: 'BB', id: 3, created_at: ref_time - 5.seconds, updated_at: ref_time - 10.seconds) }
    let!(:group4) { create(:group, name: 'bbb', id: 4, created_at: ref_time, updated_at: ref_time - 15.seconds) }

    it 'sorts groups by id' do
      expect(ordered_group_names('id_asc')).to eq(%w(aa AAA BB bbb))
      expect(ordered_group_names('id_desc')).to eq(%w(bbb BB AAA aa))
    end

    it 'sorts groups by name via case-insentitive comparision' do
      expect(ordered_group_names('name_asc')).to eq(%w(aa AAA BB bbb))
      expect(ordered_group_names('name_desc')).to eq(%w(bbb BB AAA aa))
    end

    it 'sorts groups by created_at' do
      expect(ordered_group_names('created_asc')).to eq(%w(aa AAA BB bbb))
      expect(ordered_group_names('created_desc')).to eq(%w(bbb BB AAA aa))
      expect(ordered_group_names('created_date')).to eq(%w(bbb BB AAA aa))
    end

    it 'sorts groups by updated_at' do
      expect(ordered_group_names('updated_asc')).to eq(%w(bbb BB AAA aa))
      expect(ordered_group_names('updated_desc')).to eq(%w(aa AAA BB bbb))
    end
  end
end
