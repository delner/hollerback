require 'spec_helper'

describe Hollerback do

  def mock_callbacks(klass, test_method_name, &mock_block)
    allow(klass).to receive(test_method_name) do |&callbacks|
      mock_block.call(klass.const_get("Callbacks")[callbacks])
    end
  end

  def mock_callbacks_by_block(klass, test_method_name, &mock_block)
    allow(klass).to receive(test_method_name) do |&callbacks_block|
      klass.hollerback_for(callbacks_block) do |callbacks|
        mock_block.call(callbacks)
      end
    end
  end

  let(:test_class) do
    stub_const "TestClass", Class.new
    TestClass.send(:include, Hollerback)
    TestClass
  end

  shared_examples_for "a callback that can be fired" do
    let(:callback_action) { double(:callback_action) }
    let(:callback_name) { :success }

    # Defines callbacks that can be triggered
    let(:callbacks) do
      Proc.new do |on|
        on.send(callback_name, &callback_block)
      end
    end

    context "and returns a value" do
      let(:callback_block) { Proc.new { return_value } }
      let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, callback_name) } }
      let(:return_value) { "Return value" }
      it { is_expected.to eq(return_value) }
    end
    context "and accepts no arguments" do
      let(:callback_block) { Proc.new { callback_action.invoked } }
      let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, callback_name) } }
      it do
        expect(callback_action).to receive(:invoked)
        subject
      end
    end
    context "and accepts an argument" do
      let(:callback_block) { Proc.new { |arg| callback_action.invoked(arg) } }
      let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, callback_name, argument) } }
      let(:argument) { "Single argument" }
      it do
        expect(callback_action).to receive(:invoked).with(argument)
        subject
      end
    end
    context "and accepts a variable number of arguments" do
      let(:callback_block) { Proc.new { |*args| callback_action.invoked(*args) } }
      let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, callback_name, *arguments) } }
      let(:arguments) { ["Variable", "argument", "list"] }
      it do
        expect(callback_action).to receive(:invoked).with(*arguments)
        subject
      end
    end
    context "and accepts a block argument" do
      let(:callback_block) { Proc.new { |&block| callback_action.invoked(block) } }
      let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, callback_name, &block_argument) } }
      let(:block_argument) { Proc.new { "Block argument" } }
      it do
        expect(callback_action).to receive(:invoked).with(block_argument)
        subject
      end
    end
  end

  context "callback-enabled function" do
    subject { test_class.send(test_method_name, &callbacks) }
    let(:test_method_name) { :test }

    # Adds a stub to trigger callbacks
    before(:each) do
      mock_callbacks_by_block(test_class, test_method_name, &callback_invocation)
    end

    context "which triggers a callback" do
      context "with #try_respond_with" do
        let(:callback_trigger) { :try_respond_with }
        context "but is undefined" do
          let(:callbacks) { Proc.new { } }
          let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, :non_existing_callback) } }
          it { expect(subject).to be nil }
        end
        context "and defined" do
          it_behaves_like "a callback that can be fired"
        end
      end
      context "with #respond_with" do
        let(:callback_trigger) { :respond_with }
        context "but is undefined" do
          let(:callbacks) { Proc.new { } }
          let(:callback_invocation) { Proc.new { |cbs| cbs.send(callback_trigger, :non_existing_callback) } }
          it { expect { subject }.to raise_error(NoMethodError) }
        end
        context "and defined" do
          it_behaves_like "a callback that can be fired"
        end
      end
    end
  end

  # TODO: Add explicit coverage for #hollerback_for
end
