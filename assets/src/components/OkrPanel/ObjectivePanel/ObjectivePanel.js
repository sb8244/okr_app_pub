import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'
import { Panel } from 'react-bootstrap'
import { NavLink } from 'react-router-dom'

import { KeyResult } from '@utils/api'
import { ObjectiveShape } from '@utils/propTypesUtil'

import AddKeyResult from './AddKeyResult'
import KeyResultContent from './KeyResultContent'
import ObjectiveHeading from './ObjectiveHeading'
import ContributingObjectives, { CONTRIBUTES_TO, CONTRIBUTED_TO_BY } from './ContributingObjectives'
import SelfAssessment from './SelfAssessment'

const PanelHeader = styled.div`
  color: #3a3a3a;
  font-size: inherit;
`

const SeparatedBody = styled.div`
  border-top: 1px solid #ddd;
`

function createKeyResult(okr) {
  return (params) => {
    return KeyResult.create(params).then(() => okr.keyResultCreated())
  }
}

export class ObjectivePanel extends Component {
  state = {
    assessmentFormEditing: false,
    assessmentFormVisible: false
  }

  assessmentWrapper() {
    return {
      assessment: this.props.objective.assessment,
      isEditing: this.state.assessmentFormEditing,
      onCreate: this.props.okr.objectiveAssessmentCreated,
      onUpdate: this.props.okr.objectiveAssessmentUpdated,
      toggleIsEditing: this.toggleAssessmentFormEditing.bind(this),
      toggleVisible: this.toggleAssessmentFormVisible.bind(this),
      visible: this.state.assessmentFormVisible
    }
  }

  toggleAssessmentFormEditing() {
    this.setState({
      assessmentFormEditing: !this.state.assessmentFormEditing
    })
  }

  toggleAssessmentFormVisible() {
    this.setState({
      assessmentFormVisible: !this.state.assessmentFormVisible
    })
  }

  render() {
    const { objective, okr } = this.props
    const assessmentWrapper = this.assessmentWrapper()

    return (
      <Panel className="panel--tight">
        <Panel.Heading>
          <Panel.Title componentClass={PanelHeader}>
            <ObjectiveHeading objective={objective} okr={okr} assessmentWrapper={assessmentWrapper} />
          </Panel.Title>
        </Panel.Heading>
        {
          objective.key_results.map(keyResult => (
            <Panel.Body key={keyResult.id}>
              <KeyResultContent keyResult={keyResult} okr={okr} />
            </Panel.Body>
          ))
        }
        <Panel.Body>
          <AddKeyResult objectiveId={objective.id} saveFn={createKeyResult(okr)} />
        </Panel.Body>

        {
          objective.contributes_to_objectives.length > 0 ? (
            <SeparatedBody>
              <ContributingObjectives okr={okr} objective={objective} objectives={objective.contributes_to_objectives} type={CONTRIBUTES_TO} />
            </SeparatedBody>
          ) : null
        }

        {
          objective.contributed_by_objectives.length > 0 ? (
            <SeparatedBody>
              <ContributingObjectives okr={okr} objective={objective} objectives={objective.contributed_by_objectives} type={CONTRIBUTED_TO_BY} />
            </SeparatedBody>
          ) : null
        }

        {
          assessmentWrapper.visible || objective.assessment ? (
            <SeparatedBody>
              <Panel.Body>
                <SelfAssessment objectiveId={objective.id} assessmentWrapper={assessmentWrapper} />
              </Panel.Body>
            </SeparatedBody>
          ) : null
        }
      </Panel>
    )
  }
}

ObjectivePanel.propTypes = {
  objective: PropTypes.shape(ObjectiveShape),
}
