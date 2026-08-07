function postToNui(action, payload) {
  fetch(`https://${GetParentResourceName()}/${action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload || {})
  })
  .catch(function() {})
}

window.addEventListener('message', function(event) {
  const data = event.data || {}

  if (data.type === 'setVisible') {
    document.getElementById('panel').classList.toggle('hidden', !data.visible)
  }

  if (data.type === 'notify') {
    const notice = document.createElement('div')
    notice.className = 'toast'
    notice.textContent = data.message || ''
    document.body.appendChild(notice)

    setTimeout(function() {
      notice.remove()
    }, 2500)
  }
})

document.getElementById('closeBtn').addEventListener('click', function() {
  postToNui('closePanel', {})
})

document.querySelectorAll('[data-action]').forEach(function(button) {
  button.addEventListener('click', function() {
    postToNui('performAction', { action: button.getAttribute('data-action') })
  })
})

document.addEventListener('keydown', function(event) {
  if (event.key === 'Escape') {
    postToNui('closePanel', {})
  }
})
