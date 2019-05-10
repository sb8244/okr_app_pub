import React from 'react'
import styled from 'styled-components'
import { DropdownButton, MenuItem } from 'react-bootstrap'

import { KeyResult } from '@utils/api'

const Dropdown = styled('div')`
  flex-grow: 1;
  margin-left: 25px;
  margin-right: 25px;
  text-align: right;
`

function cancelFn({ id, cancelled_at }, okr) {
  return () => {
    if (cancelled_at) {
      KeyResult.update(id, { cancelled_at: null }).then(okr.keyResultUpdated)
    } else {
      const now = (new Date()).toISOString()
      KeyResult.update(id, { cancelled_at: now }).then(okr.keyResultUpdated)
    }
  }
}

function deleteFn({ id, cancelled_at }, okr) {
  return () => {
    if (window.confirm('Are you sure you want to delete this? Cancelling is reversible, but deleting is not.')) {
      const now = (new Date()).toISOString()
      KeyResult.update(id, { deleted_at: now }).then(okr.keyResultUpdated)
    }
  }
}

function cancelText({ cancelled_at }) {
  if (cancelled_at) {
    return 'Uncancel'
  } else {
    return 'Cancel'
  }
}

export default ({ keyResult, okr }) => (
  <Dropdown>
    <DropdownButton
      bsSize="xsmall"
      pullRight
      title="actions"
      id={`key-result-actions-${keyResult.id}`}
    >
      <MenuItem eventKey="1" onClick={cancelFn(keyResult, okr)}>{cancelText(keyResult)}</MenuItem>
      <MenuItem divider />
      <MenuItem eventKey="2" onClick={deleteFn(keyResult, okr)}>Delete</MenuItem>
    </DropdownButton>
  </Dropdown>
)
