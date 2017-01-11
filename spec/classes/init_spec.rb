require 'spec_helper'
describe 'cust_haproxy' do
  context 'with default values for all parameters' do
    it { should contain_class('cust_haproxy') }
  end
end
