import React from 'react'
import ReactDOM from 'react-dom'
import './index.css'
import App from './App'
import registerServiceWorker from './registerServiceWorker'

import { User } from '@utils/api'

User.me().then((user) => {
  ReactDOM.render(<App currentUser={user} />, document.getElementById('react-app'))
  registerServiceWorker()
}).catch((e) => {
  window.location.href = '/login'
})
