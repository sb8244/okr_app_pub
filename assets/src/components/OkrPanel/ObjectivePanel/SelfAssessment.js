import React, { Component } from 'react'
import styled from 'styled-components'
import { Button, FormControl } from 'react-bootstrap'

import { ObjectiveAssessment } from '@utils/api'

const FormButton = styled(Button)`
  margin-top: 10px;
`

const Preline = styled.div`
  white-space: pre-line;
`

function submitForm({ assessment, objectiveId, onCreate, onUpdate, toggleIsEditing, toggleVisible }) {
  return (e) => {
    e.preventDefault()

    const params = {
      assessment: e.target.assessment.value,
      objective_id: objectiveId
    }

    if (assessment) {
      ObjectiveAssessment.update(assessment.id, params).then(() => {
        onUpdate()
        toggleIsEditing()
      })
    } else {
      ObjectiveAssessment.create(params).then(() => {
        onCreate()
        toggleVisible()
      })
    }
  }
}

const SelfAssessment = ({ assessmentWrapper: { assessment, isEditing, onCreate, onUpdate, toggleIsEditing, toggleVisible }, objectiveId }) => (
  <div>
    <h5>Self Assessment</h5>

    {
      assessment && !isEditing ? (
        <div onClick={toggleIsEditing}>
          <Preline>{assessment.assessment}</Preline>
        </div>
      ) : (
        <form onSubmit={submitForm({ assessment, onCreate, objectiveId, toggleIsEditing, onUpdate, toggleVisible })}>
          <FormControl
            componentClass="textarea"
            placeholder="Reflect on your objective, considering what you wanted to achieve, were able to achieve, and why..."
            required
            name="assessment"
            defaultValue={(assessment || {}).assessment}
          />
          <FormButton type="submit" bsClass="btn-xs btn-primary">Save</FormButton>
        </form>
      )
    }
  </div>
)

export default SelfAssessment
