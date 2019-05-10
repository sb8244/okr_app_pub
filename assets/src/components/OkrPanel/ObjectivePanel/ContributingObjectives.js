import React from 'react'
import styled from 'styled-components'
import { DropdownButton, MenuItem, Panel } from 'react-bootstrap'
import { NavLink } from 'react-router-dom'

import { ownerDetailPath } from '@utils/navigationUtil'
import { Objective } from '@utils/api'

export const CONTRIBUTES_TO = 'Contributes to'
export const CONTRIBUTED_TO_BY = 'Contributed to by'

const ObjectiveLink = styled(NavLink)`
  text-decoration: ${({ objective }) => objective.cancelled_at ? 'line-through' : 'none'};
`

const ObjectiveRow = styled(Panel.Body)`
  display: flex;
`

const Dropdown = styled.div`
  flex-grow: 1;
  margin-left: 25px;
  text-align: right;
`

function unlink(objective, linkedObjective, type, okr) {
  return () => {
    let contributesToObjectiveId, contributedByObjectiveId

    if (type === CONTRIBUTES_TO) {
      contributesToObjectiveId = linkedObjective.id
      contributedByObjectiveId = objective.id
    } else if (type === CONTRIBUTED_TO_BY) {
      contributesToObjectiveId = objective.id
      contributedByObjectiveId = linkedObjective.id
    }

    Objective.deleteObjectiveLink({ contributesToObjectiveId, contributedByObjectiveId }).then(() => {
      okr.objectiveLinkDeleted()
    }).catch((e) => {
      console.error(e)
      alert('Error unlinking the objectives. Check the developer console for error')
    })
  }
}

const ContributingObjectives = ({ objective, objectives, type, okr }) => (
  objectives.map(linkedObjective => (
    <ObjectiveRow key={linkedObjective.id}>
      <span>{type}&nbsp;</span>
      <NavLink to={ownerDetailPath(linkedObjective.owner)}>{linkedObjective.owner.name}'s</NavLink>
      <span>&nbsp;objective&nbsp;</span>
      <ObjectiveLink objective={linkedObjective} to={ownerDetailPath(linkedObjective.owner)}>"{linkedObjective.content}"</ObjectiveLink>

      <Dropdown>
        <DropdownButton
          bsSize="xsmall"
          pullRight
          title="actions"
          id={`link-actions-${linkedObjective.id}`}
        >
          <MenuItem onClick={unlink(objective, linkedObjective, type, okr)}>Unlink</MenuItem>
        </DropdownButton>
      </Dropdown>
    </ObjectiveRow>
  ))
)

export default ContributingObjectives
