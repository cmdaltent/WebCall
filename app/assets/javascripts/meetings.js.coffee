participantAdded = (participant) =>
  $('#participant-list .participant-list-user')
  .clone()
  .removeClass('me')
  .find('span')
  .text(participant.whoami.name)
  .parent()
  .attr('id', 'userlist-entry-'+participant.whoami.identifier)
  .appendTo('#participant-list .accordion-inner')

participantRemoved = (participant) =>
  $('#userlist-entry-'+participant.whoami.identifier).remove()
  
EventBroker.on 'rtc.user.join', participantAdded
EventBroker.on 'rtc.user.left', participantRemoved
