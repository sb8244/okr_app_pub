import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'
import moment from 'moment'
import { Badge } from 'react-bootstrap'

import { OkrShape } from '@utils/propTypesUtil'
import { ObjectivePanel } from './ObjectivePanel/ObjectivePanel'
import AddObjective from './AddObjective'
import AddOKRReflection from './AddOKRReflection'

const Wrapper = styled.div`
  margin-bottom: 50px;
`

const DurationWrapper = styled.small`
  margin-left: 20px;
  margin-right: 20px;
`

const ActiveBadge = styled(Badge)`
  background-color: green;
  font-weight: 500;
  margin-top: 2px;
`

const MOMENT_FORMAT_FOR_CYCLE = 'll'

export const OkrPanel = ({
  okr,
}) => (
  <Wrapper>
    <h2>
      <span>{okr.cycle.title}</span>
      <DurationWrapper>
        {moment(okr.cycle.starts_at).format(MOMENT_FORMAT_FOR_CYCLE)} - {moment(okr.cycle.ends_at).format(MOMENT_FORMAT_FOR_CYCLE)}
      </DurationWrapper>
      {
        okr.cycle.active ?
          <ActiveBadge bsStyle="primary">active</ActiveBadge> :
          null
      }
    </h2>
    <div>
      {
        okr.objectives.map(objective => (
          <ObjectivePanel
            key={objective.id}
            objective={objective}
            okr={okr}
          />
        ))
      }
    </div>
    <AddOKRReflection okr={okr} />
    <AddObjective okr={okr} />
  </Wrapper>
)

OkrPanel.propTypes = {
  okr: PropTypes.shape(OkrShape),
}
