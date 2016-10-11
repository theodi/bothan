Given(/^I set up a Pusher spy$/) do
  allow(Pusher).to receive(:trigger)
end

Then(/^the Pusher endpoint should have recieved "(.*?)" with "(.*?)"$/) do |metric, message|
  expect(Pusher).to have_received(:trigger).with(metric, message, {})
end
