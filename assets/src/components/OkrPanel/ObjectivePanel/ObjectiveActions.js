import React from 'react'
import styled from 'styled-components'
import { DropdownButton, MenuItem } from 'react-bootstrap'
import { toast } from 'react-toastify'

import { Objective, ObjectiveAssessment } from '@utils/api'
import { ObjectiveLinkingContext } from '@components/State/ObjectiveLinking'

const Dropdown = styled('div')`
  display: flex;

  align-items: flex-end;
  flex-direction: column;
  flex-grow: 1;
  justify-content: center;

  margin-left: 25px;
  margin-right: 25px;
`

function cancelFn({ id, cancelled_at }, okr) {
  return () => {
    if (cancelled_at) {
      Objective.update(id, { cancelled_at: null }).then(okr.objectiveUpdated)
    } else {
      const now = (new Date()).toISOString()
      Objective.update(id, { cancelled_at: now }).then(okr.objectiveUpdated)
    }
  }
}

function deleteFn({ id }, okr) {
  return () => {
    if (window.confirm('Are you sure you want to delete this? Cancelling is reversible, but deleting is not.')) {
      const now = (new Date()).toISOString()
      Objective.update(id, { deleted_at: now }).then(okr.objectiveUpdated)
    }
  }
}

function deleteAssessment({ assessment: { id }, onUpdate }) {
  return () => {
    if (window.confirm('Are you sure you want to delete this? This is not reversible.')) {
      const now = (new Date()).toISOString()
      ObjectiveAssessment.update(id, { deleted_at: now }).then(onUpdate)
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

function createObjectiveLink(objective, okr, clearLinking, getLinkingSourceId) {
  getLinkingSourceId().then((sourceId) => {
    if (sourceId == objective.id) {
      toast.error('You cannot link an objective to itself')
    } else {
      Objective.createObjectiveLink({ sourceId, targetId: objective.id })
        .then(() => {
          toast('Linking created!')
          clearLinking()
          okr.objectiveLinkCreated()
        })
        .catch((e) => {
          toast.error('Error creating objective link. Open developer console for details')
          console.error(e)
        })
    }
  }).catch((e) => {
    toast.error('Error creatingg objective link. Open developer console for details')
    console.error(e)
  })
}

function beginObjectiveLink(setLinking, objective) {
  toast('Navigate to the objective you want to link to, and "Save Linking"')
  setLinking(objective)
}

export default ({ assessmentWrapper, objective, okr }) => (
  <ObjectiveLinkingContext.Consumer>
  {
    ({ clearLinking, getLinkingSourceId, linkingCode, setLinking }) => (
      <Dropdown>
        <DropdownButton
          bsSize="xsmall"
          pullRight
          title="actions"
          id={`objective-actions-${objective.id}`}
        >
          {
            linkingCode ? ([
              <MenuItem key="create" onClick={() => createObjectiveLink(objective, okr, clearLinking, getLinkingSourceId)}>Save Linking (is contributed to)</MenuItem>,
              <MenuItem key="cancel" onClick={() => clearLinking()}>Cancel Linking</MenuItem>
            ]) : (
              <MenuItem onClick={() => beginObjectiveLink(setLinking, objective)}>Begin Linking (contributes to)</MenuItem>
            )
          }
          <MenuItem onClick={cancelFn(objective, okr)}>{cancelText(objective)}</MenuItem>
          <MenuItem divider />
          {
            assessmentWrapper.assessment ? (
              <MenuItem onClick={deleteAssessment(assessmentWrapper)}>Delete self-assessment</MenuItem>
            ) : (
              <MenuItem onClick={assessmentWrapper.toggleVisible}>Add self-assessment</MenuItem>
            )
          }
          <MenuItem divider />
          <MenuItem onClick={deleteFn(objective, okr)}>Delete</MenuItem>
        </DropdownButton>
      </Dropdown>
    )
  }
  </ObjectiveLinkingContext.Consumer>
)
